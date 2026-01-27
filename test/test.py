# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, Timer


UART_TX_BIT = 2      # uo_out[2]
CLK_PERIOD_US = 10   # 100 kHz clock


@cocotb.test()
async def test_project(dut):
    dut._log.info("=== START TEST ===")

    # ------------------------------------------------------------
    # Clock
    # ------------------------------------------------------------
    clock = Clock(dut.clk, CLK_PERIOD_US, unit="us")
    cocotb.start_soon(clock.start())

    # ------------------------------------------------------------
    # Reset (ACTIVE HIGH)
    # ------------------------------------------------------------
    dut._log.info("Apply reset")

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    dut.rst_n.value = 1   # ACTIVE HIGH reset
    await ClockCycles(dut.clk, 20)

    dut.rst_n.value = 0   # release reset
    await ClockCycles(dut.clk, 50)

    dut._log.info("Reset released")

    # ------------------------------------------------------------
    # Wait until UART TX becomes resolvable & idle (HIGH)
    # ------------------------------------------------------------
    dut._log.info("Waiting for UART idle")

    while True:
        await RisingEdge(dut.clk)
        tx = dut.uo_out[UART_TX_BIT].value

        if tx.is_resolvable and tx.integer == 1:
            break

    dut._log.info("UART idle detected")

    # ------------------------------------------------------------
    # Simulate button press (debounced input)
    # ------------------------------------------------------------
    dut._log.info("Press button")
    dut.ui_in.value = 0b00000100

    await ClockCycles(dut.clk, 400000)

    # ------------------------------------------------------------
    # Wait for UART START BIT (TX goes LOW)
    # ------------------------------------------------------------
    dut._log.info("Waiting for UART start bit")

    timeout_cycles = 20000
    for _ in range(timeout_cycles):
        await RisingEdge(dut.clk)
        tx = dut.uo_out[UART_TX_BIT].value

        if tx.is_resolvable and tx.integer == 0:
            dut._log.info("UART start bit detected")
            break
    else:
        assert False, "UART start bit not detected (timeout)"

    # ------------------------------------------------------------
    # Release button
    # ------------------------------------------------------------
    dut._log.info("Release button")
    dut.ui_in.value = 0

    await ClockCycles(dut.clk, 500)

    dut._log.info("=== TEST PASSED ===")
