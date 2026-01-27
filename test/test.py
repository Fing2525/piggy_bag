# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, Timer
from cocotb.result import TestFailure


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start test")

    # ------------------------------------------------------------
    # Timeout task (prevents infinite hang)
    # ------------------------------------------------------------
    async def timeout():
        await Timer(5, "ms")
        raise TestFailure("Simulation timeout")

    cocotb.start_soon(timeout())

    # ------------------------------------------------------------
    # Clock: 100 MHz (1 ns period)
    # ------------------------------------------------------------
    clock = Clock(dut.clk, 1, unit="ns")
    cocotb.start_soon(clock.start())

    # ------------------------------------------------------------
    # Initial values
    # ------------------------------------------------------------
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    # ------------------------------------------------------------
    # Apply reset
    # ------------------------------------------------------------
    dut._log.info("Applying reset")
    await ClockCycles(dut.clk, 20)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 50)

    # ------------------------------------------------------------
    # Wait for UART idle (TX must be HIGH)
    # ------------------------------------------------------------
    dut._log.info("Waiting for UART idle")

    for _ in range(200):
        await RisingEdge(dut.clk)

    tx = int(dut.uo_out.value) & 0b1
    assert tx == 1, "UART TX not idle after reset"

    dut._log.info("UART idle confirmed")

    # ------------------------------------------------------------
    # Apply stimulus (button / coin input)
    # ------------------------------------------------------------
    dut._log.info("Applying input stimulus")
    dut.ui_in.value = 0b00000100
    await ClockCycles(dut.clk, 400)
    dut.ui_in.value = 0

    # ------------------------------------------------------------
    # Detect REAL UART start bit (1 -> 0)
    # ------------------------------------------------------------
    dut._log.info("Waiting for UART start bit")

    prev = 1
    while True:
        await RisingEdge(dut.clk)
        curr = int(dut.uo_out.value) & 0b1
        if prev == 1 and curr == 0:
            break
        prev = curr

    dut._log.info("UART start bit detected ✔")

    # ------------------------------------------------------------
    # Optional: wait some cycles to observe waveform
    # ------------------------------------------------------------
    await ClockCycles(dut.clk, 500)

    dut._log.info("Test completed successfully")