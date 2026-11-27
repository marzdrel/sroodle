import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

import CopyButton from '@/components/CopyButton';
import { renderWithInertia } from '@/test-utils/testing-library-utils';

describe('CopyButton', () => {
  afterEach(() => {
    vi.restoreAllMocks();
    Object.defineProperty(navigator, 'share', { value: undefined, configurable: true });
  });

  test('copies the value and confirms it', async () => {
    const user = userEvent.setup();
    const writeText = vi.spyOn(navigator.clipboard, 'writeText').mockResolvedValue();

    renderWithInertia(<CopyButton value="https://sroodle.test/poll_1" label="Copy poll link" />);
    await user.click(screen.getByRole('button', { name: 'Copy poll link' }));

    expect(writeText).toHaveBeenCalledWith('https://sroodle.test/poll_1');
    expect(await screen.findByText('Copied!')).toBeInTheDocument();
  });

  test('uses the system share sheet when available', async () => {
    const user = userEvent.setup();
    const share = vi.fn().mockResolvedValue(undefined);
    Object.defineProperty(navigator, 'share', { value: share, configurable: true });
    const writeText = vi.spyOn(navigator.clipboard, 'writeText').mockResolvedValue();

    renderWithInertia(<CopyButton value="https://sroodle.test/poll_1" label="Share poll" share={{ title: 'Game night' }} />);
    await user.click(screen.getByRole('button', { name: 'Share poll' }));

    expect(share).toHaveBeenCalledWith({ title: 'Game night', url: 'https://sroodle.test/poll_1' });
    expect(writeText).not.toHaveBeenCalled();
  });

  test('falls back to copying when sharing is cancelled', async () => {
    const user = userEvent.setup();
    Object.defineProperty(navigator, 'share', { value: vi.fn().mockRejectedValue(new Error('AbortError')), configurable: true });
    const writeText = vi.spyOn(navigator.clipboard, 'writeText').mockResolvedValue();

    renderWithInertia(<CopyButton value="https://sroodle.test/poll_1" label="Share poll" share={{ title: 'Game night' }} />);
    await user.click(screen.getByRole('button', { name: 'Share poll' }));

    expect(writeText).toHaveBeenCalledWith('https://sroodle.test/poll_1');
  });
});
