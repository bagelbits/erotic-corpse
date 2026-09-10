import React from 'react';
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import ReportModal from 'components/app/ReportModal';

const props = (overrides = {}) => ({
  open: true,
  onClose: vi.fn(),
  onReport: vi.fn(),
  promptId: 42,
  ...overrides,
});

describe('ReportModal', () => {
  it('stays hidden until it is opened', () => {
    render(<ReportModal {...props({ open: false })} />);

    expect(screen.queryByText('Are you sure you want to report this?')).not.toBeInTheDocument();
  });

  it('explains what reporting does', () => {
    render(<ReportModal {...props()} />);

    expect(screen.getByText('Are you sure you want to report this?')).toBeInTheDocument();
    expect(screen.getByText(/remove it from the story/)).toBeInTheDocument();
    expect(screen.getByText(/already been locked into the story/)).toBeInTheDocument();
  });

  it('reports the prompt it was given', async () => {
    const onReport = vi.fn();
    render(<ReportModal {...props({ onReport })} />);

    await userEvent.click(screen.getByRole('button', { name: 'Report' }));

    expect(onReport).toHaveBeenCalledWith(42);
  });

  it('closes without reporting when cancelled', async () => {
    const onClose = vi.fn();
    const onReport = vi.fn();
    render(<ReportModal {...props({ onClose, onReport })} />);

    await userEvent.click(screen.getByRole('button', { name: 'Cancel' }));

    expect(onClose).toHaveBeenCalled();
    expect(onReport).not.toHaveBeenCalled();
  });
});
