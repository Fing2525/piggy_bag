# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

UART_TX_BIT = 2
CLK_PERIOD_NS = 20   # 50 MHz


def get_uart_tx(dut):
    """Safely read UART TX bit.
       Returns: 0, 1, or None (if X/Z)"""
    if not dut.uo_out.value.is_resolvable:
        return None

    val = dut.uo_out.value.to_unsigned()
    return (val >> UART_TX_BIT) & 1


@cocotb.test()
async def test_project(dut):
    dut._log.info("=== START GL-SAFE UART TEST ===")

    # ------------------------------------------------------------
    # Clock
    # ------------------------------------------------------------
    clock = Clock(dut.clk, CLK_PERIOD_NS, unit="ns")
    cocotb.start_soon(clock.start())

    # ------------------------------------------------------------
    # Initial inputs
    # ------------------------------------------------------------
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # ------------------------------------------------------------
    # Reset (ACTIVE HIGH in your design)
    # ------------------------------------------------------------
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 20)

    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 50)

    dut._log.info("Reset released")

    # ------------------------------------------------------------
    # Let GL signals settle (IMPORTANT)
    # ------------------------------------------------------------
    await ClockCycles(dut.clk, 100)

    # ------------------------------------------------------------
    # Press button (debounced input)
    # ------------------------------------------------------------
    dut._log.info("Pressing button")
    dut.ui_in.value = 0b00000100
    await ClockCycles(dut.clk, 400_000)

    # ------------------------------------------------------------
    # Wait for UART START BIT (1 -> 0 transition)
    # ------------------------------------------------------------
    dut._log.info("Waiting for UART start bit (falling edge)")

    last_tx = None
    timeout_cycles = 200_000

    for _ in range(timeout_cycles):
        await RisingEdge(dut.clk)

        tx = get_uart_tx(dut)
        if tx is None:
            continue

        # Detect falling edge: idle(1) -> start bit(0)
        if last_tx == 1 and tx == 0:
            dut._log.info("UART start bit detected")
            break

        last_tx = tx
    else:
        assert False, "UART start bit not detected (GL timeout)"

    # ------------------------------------------------------------
    # Release button
    # ------------------------------------------------------------
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 500)

    dut._log.info("=== TEST PASSED ===")
