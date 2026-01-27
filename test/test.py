# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, Timer


UART_TX_BIT = 2   # <<< uo_out[2] is UART TX


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start test")

    # ------------------------------------------------------------
    # Timeout watchdog (cocotb v2 style)
    # ------------------------------------------------------------
    async def timeout():
        await Timer(5, "ms")
        assert False, "Simulation timeout"

    cocotb.start_soon(timeout())

    # ------------------------------------------------------------
    # Clock: 100 MHz (10 ns period)
    # ------------------------------------------------------------
    clock = Clock(dut.clk, 1, unit="ns")
    cocotb.start_soon(clock.start())

    # ------------------------------------------------------------
    # Initial values
    # ------------------------------------------------------------
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 1

    # ------------------------------------------------------------
    # Reset
    # ------------------------------------------------------------
    dut._log.info("Applying reset")
    await ClockCycles(dut.clk, 20)
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 50)

    # ------------------------------------------------------------
    # Check UART idle state (TX must be HIGH)
    # ------------------------------------------------------------
    dut._log.info("Checking UART idle on uo_out[2]")

    await ClockCycles(dut.clk, 200)

    tx_idle = (int(dut.uo_out.value) >> UART_TX_BIT) & 1
    assert tx_idle == 1, "UART TX not idle after reset"

    dut._log.info("UART idle confirmed")

    # ------------------------------------------------------------
    # Apply stimulus (button press)
    # ------------------------------------------------------------
    dut._log.info("Applying input stimulus")
    dut.ui_in.value = 0b00000100
    await ClockCycles(dut.clk, 400)
    dut.ui_in.value = 0

    # ------------------------------------------------------------
    # Wait for UART start bit (1 -> 0)
    # ------------------------------------------------------------
    dut._log.info("Waiting for UART start bit on uo_out[2]")

    prev = 1
    while True:
        await RisingEdge(dut.clk)
        curr = (int(dut.uo_out.value) >> UART_TX_BIT) & 1
        if prev == 1 and curr == 0:
            break
        prev = curr

    dut._log.info("UART start bit detected ✔")

    # ------------------------------------------------------------
    # Let waveform continue
    # ------------------------------------------------------------
    await ClockCycles(dut.clk, 500)

    dut._log.info("Test finished successfully ✅")
