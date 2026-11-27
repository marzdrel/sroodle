import { router } from '@inertiajs/react';
import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

import Edit from '@/pages/Poll/Edit';
import { renderWithInertia } from '@/test-utils/testing-library-utils';

const values = {
  event: 'Board game night',
  description: 'Bring snacks',
  end_voting_at: '2030-01-10',
  options: [
    { date: '2030-01-12', time: '', duration_minutes: 1440 },
    { date: '2030-01-13', time: '18:00', duration_minutes: 90 },
  ],
};

const props = {
  poll: { id: 'poll_123', name: 'Board game night', path: '/poll_123' },
  values,
  submit_path: '/poll_123/admin/secret',
  admin_path: '/poll_123/admin/secret',
  time_zone: 'Europe/Warsaw',
};

describe('Poll Edit page', () => {
  test('shows the current values', () => {
    renderWithInertia(<Edit {...props} />);

    expect(screen.getByLabelText('Event')).toHaveValue('Board game night');
    expect(screen.getByLabelText('Description')).toHaveValue('Bring snacks');
    expect(screen.getByLabelText('Voting deadline')).toHaveValue('2030-01-10');
    expect(screen.getByLabelText('Start time')).toHaveValue('18:00');
    expect(screen.getByText(/Europe\/Warsaw/)).toBeInTheDocument();
  });

  test('submits the edited values with PATCH', async () => {
    renderWithInertia(<Edit {...props} />);

    const event = screen.getByLabelText('Event');
    await userEvent.clear(event);
    await userEvent.type(event, 'Game night');
    await userEvent.click(screen.getByRole('button', { name: 'Save changes' }));

    expect(router.patch).toHaveBeenCalledWith(
      '/poll_123/admin/secret',
      { poll: { ...values, event: 'Game night' } },
      expect.any(Object)
    );
  });

  test('shows server errors', () => {
    renderWithInertia(<Edit {...props} errors={{ event: 'Event is too short', options: 'Options must include at least 2' }} />);

    expect(screen.getByText('Event is too short')).toBeInTheDocument();
    expect(screen.getByText('Options must include at least 2')).toBeInTheDocument();
  });
});
