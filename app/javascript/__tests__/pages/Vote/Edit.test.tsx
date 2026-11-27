import { router } from '@inertiajs/react';
import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

import Edit from '@/pages/Vote/Edit';
import { renderWithInertia } from '@/test-utils/testing-library-utils';

const poll = {
  id: 'poll_123',
  name: 'Board game night',
  description: '',
  path: '/poll_123',
  options: [
    { id: 'popt_1', start: '2030-01-10T00:00:00Z', duration_minutes: 1440 },
  ],
};

const vote = { name: 'Carol', email: '', responses: { popt_1: 'yes' } };

describe('Vote Edit page', () => {
  test('prefills the participant answers and shows their personal link', () => {
    renderWithInertia(
      <Edit poll={poll} vote={vote} submit_path="/poll_123/votes" edit_link="/poll_123/p/token123" />
    );

    expect(screen.getByDisplayValue('Carol')).toBeInTheDocument();
    expect(screen.getByTestId('edit-link')).toHaveTextContent('/poll_123/p/token123');
  });

  test('submits the answers with PATCH to the given path', async () => {
    renderWithInertia(<Edit poll={poll} vote={vote} submit_path="/poll_123/votes" />);

    await userEvent.click(screen.getByRole('button', { name: /update vote/i }));

    expect(router.patch).toHaveBeenCalledWith(
      '/poll_123/votes',
      { vote: { name: 'Carol', email: '', responses: { popt_1: 'yes' } } },
      expect.any(Object)
    );
  });
});
