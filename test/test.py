# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start test")

    # -------------------------
    # Timeout guard
    # -------------------------
    async def timeout():
        await Timer(100, "ms")
        raise cocotb.result.TestFailure("Simulation timeout")

    cocotb.start_soon(timeout())

    # -------------------------
    # Clock: 100 kHz
    # -------------------------
    clock = Clock(dut.clk, 1, unit="ns")
    cocotb.start_soon(clock.start())

    # -------------------------
    # Reset
    # -------------------------
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 20)

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 50)

    # -------------------------
    # Apply stimulus (button press)
    # -------------------------
    dut._log.info("Apply input")
    dut.ui_in.value = 0b00000100
    await ClockCycles(dut.clk, 400)

    # -------------------------
    # Wait for UART TX start bit
    # uo_out[0] goes 1 -> 0
    # -------------------------
    dut._log.info("Waiting for UART TX activity")

    # Wait until TX goes low (start bit)
    while int(dut.uo_out.value) & 0b1 == 1:
        await RisingEdge(dut.clk)

    dut._log.info("UART start bit detected")

    # -------------------------
    # Sample a few UART bits (example)
    # -------------------------
    baud_cycles = 104  # adjust if your baud differs
    bits = []

    # Sample 8 data bits
    for i in range(8):
        await ClockCycles(dut.clk, baud_cycles)
        bit = int(dut.uo_out.value) & 0b1
        bits.append(bit)

    dut._log.info(f"UART bits received: {bits}")

    # -------------------------
    # Simple assertion:
    # at least one bit toggled
    # -------------------------
    assert any(bits), "UART transmitted all-zero data"

    # -------------------------
    # Button release
    # -------------------------
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 500)

    dut._log.info("Test finished successfully")
