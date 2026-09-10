import React from 'react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { render, screen, act } from '@testing-library/react';
import CountdownTimer from 'components/app/CountdownTimer';

const START = new Date('2026-01-01T00:00:00Z').getTime();

describe('CountdownTimer', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(START);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('renders the remaining time as minutes and padded seconds', () => {
    render(<CountdownTimer date={START + 180 * 1000} onFinish={vi.fn()} />);

    expect(screen.getByText('3:00')).toBeInTheDocument();
  });

  it('pads seconds below ten', () => {
    render(<CountdownTimer date={START + 65 * 1000} onFinish={vi.fn()} />);

    expect(screen.getByText('1:05')).toBeInTheDocument();
  });

  it('counts down as time passes', () => {
    render(<CountdownTimer date={START + 180 * 1000} onFinish={vi.fn()} />);

    act(() => {
      vi.advanceTimersByTime(61 * 1000);
    });

    expect(screen.getByText('1:59')).toBeInTheDocument();
  });

  it('calls onFinish once the countdown reaches zero', () => {
    const onFinish = vi.fn();
    render(<CountdownTimer date={START + 5 * 1000} onFinish={onFinish} />);

    expect(onFinish).not.toHaveBeenCalled();

    act(() => {
      vi.advanceTimersByTime(6 * 1000);
    });

    expect(onFinish).toHaveBeenCalled();
  });
});
