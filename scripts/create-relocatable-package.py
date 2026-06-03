#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2018-present ScyllaDB
#

#
# SPDX-License-Identifier: AGPL-3.0-or-later
#

import argparse
import os
import shutil
import subprocess
import tarfile
import pathlib
import sys
import tempfile


RELOC_PREFIX='scylla'
def reloc_add(self, name, arcname=None, recursive=True, *, filter=None):
    if arcname:
        return self.add(name, arcname="{}/{}".format(RELOC_PREFIX, arcname),
                        filter=filter)
    else:
        return self.add(name, arcname="{}/{}".format(RELOC_PREFIX, name),
                        filter=filter)

tarfile.TarFile.reloc_add = reloc_add

def ldd(executable):
    '''Given an executable file, return a dictionary with the keys
    containing its shared library dependencies and the values pointing
    at the files they resolve to. A fake key ld.so points at the
    dynamic loader.'''
    libraries = {}
    ldd_result = subprocess.run(
            ['ldd', executable],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
    ldd_output = ldd_result.stdout + ldd_result.stderr
    if ldd_result.returncode != 0:
        if 'not a dynamic executable' in ldd_output:
            return libraries
        raise subprocess.CalledProcessError(
            ldd_result.returncode,
            ldd_result.args,
            output=ldd_result.stdout,
            stderr=ldd_result.stderr)

    for ldd_line in ldd_output.splitlines():
        elements = ldd_line.split()
        if not elements:
            continue
        if ldd_line == 'statically linked':
            continue
        if ldd_line.endswith('not found'):
            raise Exception('ldd {}: could not resolve {}'.format(executable, elements[0]))
        if len(elements) < 2:
            continue
        if elements[1] != '=>':
            if elements[0].startswith('linux-vdso.so'):
                # provided by kernel
                continue
            libraries['ld.so'] = os.path.realpath(elements[0])
        elif '//' in elements[0]:
            # We know that the only DSO with a // in the path is the
            # dynamic linker used by scylla, which is the same ld.so
            # above.
            pass
        else:
            libraries[elements[0]] = os.path.realpath(elements[2])
    return libraries

def filter_dist(info):
    for x in ['dist/ami/files/', 'dist/ami/packer', 'dist/ami/variables.json']:
        if info.name.startswith(x):
            return None
    return info

def executable(path, arcname=None):
    return (path, arcname or os.path.basename(path))

def distrocmd(name, fallback_dir='/usr/bin'):
    path = shutil.which(name) or os.path.join(fallback_dir, name)
    wrapped = os.path.join(os.path.dirname(path), f'.{os.path.basename(path)}-wrapped')
    if os.path.exists(wrapped):
        return executable(wrapped, name)
    return executable(path, name)

def find_thread_db(libs):
    candidates = ['/lib64/libthread_db.so']
    for libfile in libs.values():
        if os.path.basename(libfile).startswith('libc.so'):
            libdir = os.path.dirname(libfile)
            candidates.extend([
                os.path.join(libdir, 'libthread_db.so'),
                os.path.join(libdir, 'libthread_db.so.1'),
            ])
    for candidate in candidates:
        if os.path.exists(candidate):
            return os.path.realpath(candidate)
    return None

SCYLLA_DIR='scylla-package'
def reloc_add(ar, name, arcname=None):
    ar.add(name, arcname="{}/{}".format(SCYLLA_DIR, arcname if arcname else name))

ap = argparse.ArgumentParser(description='Create a relocatable scylla package.')
ap.add_argument('dest',
                help='Destination file (tar format)')
ap.add_argument('--build-dir', default='build/release',
                help='Build dir ("build/debug" or "build/release") to use')
ap.add_argument('--node-exporter-dir', default='build/node_exporter',
                help='the directory where node_exporter is located')
ap.add_argument('--debian-dir', default='build/debian/debian',
                help='the directory where debian packaging is located')
ap.add_argument('--stripped', action='store_true',
                help='use stripped binaries')
ap.add_argument('--print-libexec', action='store_true',
                help='print libexec executables and exit script')

args = ap.parse_args()

executables_scylla = [
                executable('{}/scylla'.format(args.build_dir)),
                executable('{}/iotune'.format(args.build_dir))]
executables_distrocmd = [
                distrocmd('patchelf'),
                distrocmd('lscpu'),
                distrocmd('gawk'),
                distrocmd('gzip'),
                distrocmd('ifconfig', '/usr/sbin'),
                distrocmd('ethtool', '/usr/sbin'),
                distrocmd('netstat'),
                distrocmd('hwloc-distrib'),
                distrocmd('hwloc-calc'),
                distrocmd('lsblk')]

executables = executables_scylla + executables_distrocmd

if args.print_libexec:
    for _, exec_name in executables:
        print(f'libexec/{exec_name}')
    sys.exit(0)

output = args.dest

libs = {}
for exe, _ in executables:
    libs.update(ldd(exe))

# Manually add libthread_db for thread debugging when the active libc provides it.
thread_db = find_thread_db(libs)
if thread_db:
    libs.update({'libthread_db.so.1': thread_db})

ld_so = libs['ld.so']

have_gnutls = any([lib.startswith('libgnutls.so')
                   for lib in libs.keys()])

# Although tarfile.open() can write directly to a compressed tar by using
# the "w|gz" mode, it does so using a slow Python implementation. It is as
# much as 3 times faster (!) to output to a pipe running the external gzip
# command. We can complete the compression even faster by using the pigz
# command - a parallel implementation of gzip utilizing all processors
# instead of just one.
gzip_process = subprocess.Popen("pigz > "+output, shell=True, stdin=subprocess.PIPE)

ar = tarfile.open(fileobj=gzip_process.stdin, mode='w|')
# relocatable package format version = 3.0
with tempfile.NamedTemporaryFile('w+t') as version_file:
    version_file.write('3.0\n')
    version_file.flush()
    ar.add(version_file.name, arcname='.relocatable_package_version')

for exe, exe_name in executables_scylla:
    if not args.stripped:
        ar.reloc_add(exe, arcname=f'libexec/{exe_name}')
    else:
        ar.reloc_add(f'{exe}.stripped', arcname=f'libexec/{exe_name}')
for exe, exe_name in executables_distrocmd:
    ar.reloc_add(exe, arcname=f'libexec/{exe_name}')

for lib, libfile in libs.items():
    ar.reloc_add(libfile, arcname='libreloc/' + lib)
if have_gnutls:
    gnutls_config_nolink = os.path.realpath('/etc/crypto-policies/back-ends/gnutls.config')
    if os.path.exists(gnutls_config_nolink):
        ar.reloc_add(gnutls_config_nolink, arcname='libreloc/gnutls.config')
    ar.reloc_add('conf')
ar.reloc_add('dist', filter=filter_dist)
with tempfile.NamedTemporaryFile('w') as relocatable_file:
    ar.reloc_add(relocatable_file.name, arcname='SCYLLA-RELOCATABLE-FILE')
version_dir = pathlib.Path(args.build_dir)
if not (version_dir / 'SCYLLA-RELEASE-FILE').exists():
    version_dir = version_dir.parent
ar.reloc_add(version_dir / 'SCYLLA-RELEASE-FILE', arcname='SCYLLA-RELEASE-FILE')
ar.reloc_add(version_dir / 'SCYLLA-VERSION-FILE', arcname='SCYLLA-VERSION-FILE')
ar.reloc_add(version_dir / 'SCYLLA-PRODUCT-FILE', arcname='SCYLLA-PRODUCT-FILE')
ar.reloc_add('seastar/scripts')
ar.reloc_add('seastar/dpdk/usertools')
ar.reloc_add('install.sh')
# scylla_post_install.sh lives at the top level together with install.sh in the src tree, but while install.sh is
# not distributed in the .rpm and .deb packages, scylla_post_install is, so we'll add it in the package
# together with the other scripts that will end up in /usr/lib/scylla
ar.reloc_add('scylla_post_install.sh', arcname="dist/common/scripts/scylla_post_install.sh")
ar.reloc_add('README.md')
ar.reloc_add('NOTICE.txt')
ar.reloc_add('ORIGIN')
ar.reloc_add('licenses')
ar.reloc_add('swagger-ui')
ar.reloc_add('api')
ar.reloc_add('tools/scyllatop')
ar.reloc_add('scylla-gdb.py')
ar.reloc_add('bin/nodetool')
ar.reloc_add(args.debian_dir, arcname='debian')
node_exporter_dir = args.node_exporter_dir
if args.stripped:
    ar.reloc_add(f'{node_exporter_dir}', arcname='node_exporter')
    ar.reloc_add(f'{node_exporter_dir}/node_exporter.stripped', arcname='node_exporter/node_exporter')
else:
    ar.reloc_add(f'{node_exporter_dir}/node_exporter', arcname='node_exporter/node_exporter')
ar.reloc_add(f'{node_exporter_dir}/LICENSE', arcname='node_exporter/LICENSE')
ar.reloc_add(f'{node_exporter_dir}/NOTICE', arcname='node_exporter/NOTICE')
ar.reloc_add('ubsan-suppressions.supp')
ar.reloc_add('fix_system_distributed_tables.py')

# Complete the tar output, and wait for the gzip process to complete
ar.close()
gzip_process.communicate()
if gzip_process.returncode != 0:
    print(f'pigz returned {gzip_process.returncode}!', file=sys.stderr)
    sys.exit(1)
