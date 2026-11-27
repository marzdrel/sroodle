import { router } from '@inertiajs/react';
import { screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

import Admin from '@/pages/Poll/Admin';
import { renderWithInertia } from '@/test-utils/testing-library-utils';

const poll = {
  id: 'poll_123',
  name: 'Board game night',
  description: '',
  organizer_name: 'Carol',
  end_voting_at: '2030-01-10T23:59:59Z',
  path: '/poll_123',
};

const links = {
  public: 'https://sroodle.test/poll_123',
  vote: 'https://sroodle.test/poll_123/vote',
  admin: 'https://sroodle.test/poll_123/admin/secret',
};

const options = [
  { id: 'popt_1', start: '2030-01-12T00:00:00Z', duration_minutes: 1440, counts: { yes: 3, maybe: 0, no: 1 } },
  { id: 'popt_2', start: '2030-01-13T00:00:00Z', duration_minutes: 1440, counts: { yes: 1, maybe: 2, no: 1 } },
];

const baseProps = {
  poll,
  links,
  participants_count: 4,
  options,
  best_option_ids: ['popt_1'],
  closed: false,
  voting_open: true,
  final_option_id: null,
  close_path: '/poll_123/admin/secret/close',
  reopen_path: '/poll_123/admin/secret/reopen',
  edit_path: '/poll_123/admin/secret/edit',
  destroy_path: '/poll_123/admin/secret',
  participants: [
    { id: 'part_1', name: 'Dave', email: 'dave@example.com', remove_path: '/poll_123/admin/secret/participants/part_1' },
  ],
};

describe('Poll Admin page', () => {
  test('shows the public poll link and the private admin link', () => {
    renderWithInertia(<Admin {...baseProps} />);

    expect(screen.getByText('Board game night')).toBeInTheDocument();
    expect(screen.getByText(links.public)).toBeInTheDocument();
    expect(screen.getByText(links.admin)).toBeInTheDocument();
    expect(screen.getByText(/don't share it/)).toBeInTheDocument();
  });

  test('shows how many people answered and a flash notice', () => {
    renderWithInertia(<Admin {...baseProps} participants_count={1} />, {
      inertiaProps: { flash: { notice: 'Poll created. Save the admin link below.' } },
    });

    expect(screen.getByText(/1 person has answered/)).toBeInTheDocument();
    expect(screen.getByRole('status')).toHaveTextContent('Poll created');
  });

  test('lists the dates with counts and marks the best one', () => {
    renderWithInertia(<Admin {...baseProps} />);

    const best = screen.getByTestId('option-popt_1');
    expect(within(best).getByText('Best')).toBeInTheDocument();
    expect(best).toHaveTextContent('3 yes · 0 maybe · 1 no');
    expect(within(screen.getByTestId('option-popt_2')).queryByText('Best')).not.toBeInTheDocument();
  });

  test('picking a date posts it to the close path', async () => {
    renderWithInertia(<Admin {...baseProps} />);

    const second = screen.getByTestId('option-popt_2');
    await userEvent.click(within(second).getByRole('button', { name: 'Pick this date' }));

    expect(router.post).toHaveBeenCalledWith('/poll_123/admin/secret/close', { option_id: 'popt_2' });
  });

  test('a closed poll shows the chosen date and can be reopened', async () => {
    renderWithInertia(<Admin {...baseProps} closed voting_open={false} final_option_id="popt_2" />);

    expect(within(screen.getByTestId('option-popt_2')).getByText('Chosen')).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Pick this date' })).not.toBeInTheDocument();

    await userEvent.click(screen.getByRole('button', { name: 'Reopen voting' }));
    expect(router.post).toHaveBeenCalledWith('/poll_123/admin/secret/reopen');
  });

  test('links to the edit page and lists participants', () => {
    renderWithInertia(<Admin {...baseProps} />);

    expect(screen.getByRole('link', { name: 'Edit poll' })).toHaveAttribute('href', '/poll_123/admin/secret/edit');
    const row = screen.getByTestId('participant-part_1');
    expect(row).toHaveTextContent('Dave');
    expect(row).toHaveTextContent('dave@example.com');
  });

  test('removing a participant asks first', async () => {
    const confirm = vi.spyOn(window, 'confirm').mockReturnValue(true);
    renderWithInertia(<Admin {...baseProps} />);

    await userEvent.click(within(screen.getByTestId('participant-part_1')).getByRole('button', { name: 'Remove' }));

    expect(confirm).toHaveBeenCalled();
    expect(router.delete).toHaveBeenCalledWith('/poll_123/admin/secret/participants/part_1');
    confirm.mockRestore();
  });

  test('deleting the poll does nothing when not confirmed', async () => {
    const confirm = vi.spyOn(window, 'confirm').mockReturnValue(false);
    vi.mocked(router.delete).mockClear();
    renderWithInertia(<Admin {...baseProps} />);

    await userEvent.click(screen.getByRole('button', { name: 'Delete poll' }));

    expect(router.delete).not.toHaveBeenCalled();
    confirm.mockRestore();
  });
});
