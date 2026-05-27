#
# Copyright (C) 2026-present Inngest, Inc.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#
import pytest

from test.pylib.host_registry import HostRegistry


@pytest.mark.asyncio
async def test_host_registry_retires_released_hosts() -> None:
    hosts = HostRegistry()
    try:
        first = await hosts.lease_host()
        await hosts.release_host(first)

        second = await hosts.lease_host()

        assert second != first
    finally:
        await hosts.cleanup()


@pytest.mark.asyncio
async def test_host_registry_allocates_across_16_bit_loopback_subnet() -> None:
    hosts = HostRegistry()
    leased = []
    try:
        for _ in range(255):
            leased.append(await hosts.lease_host())

        octets = [int(part) for part in leased[-1].split(".")]
        assert octets[0] == 127
        assert 1 <= octets[1] <= 253
        assert octets[2:] == [1, 1]
    finally:
        for host in leased:
            await hosts.release_host(host)
        await hosts.cleanup()
