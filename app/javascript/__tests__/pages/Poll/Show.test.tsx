import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

import Show from '@/pages/Poll/Show';
import { renderWithInertia } from '@/test-utils/testing-library-utils';

// Sample mock data
const mockPoll = {
  id: '1',
  eid: 'poll_123456',
  name: 'Team Offsite',
  event: 'Team Offsite',
  description: 'Planning our annual team offsite event',
  creator: {
    email: 'jane.doe@example.com',
    name: 'Jane Doe'
  },
  created_at: '2025-05-15T10:00:00Z',
  dates: [
    {
      date: '2025-06-15',
      responses: {
        yes: 3,
        maybe: 1,
        no: 0
      }
    },
    {
      date: '2025-06-22',
      responses: {
        yes: 2,
        maybe: 2,
        no: 1
      }
    }
  ]
};

const mockParticipants = [
  {
    id: 1,
    name: 'Alice Smith',
    email: 'alice.smith@example.com',
    responses: [
      {
        date: '2025-06-15',
        preference: 'yes'
      },
      {
        date: '2025-06-22',
        preference: 'maybe'
      }
    ]
  },
  {
    id: 2,
    name: 'Bob Johnson',
    email: 'bob.johnson@example.com',
    responses: [
      {
        date: '2025-06-15',
        preference: 'yes'
      },
      {
        date: '2025-06-22',
        preference: 'no'
      }
    ]
  }
];

describe('Poll Show Component', () => {
  test('renders poll details correctly', () => {
    renderWithInertia(<Show poll={mockPoll} participants={mockParticipants} />);

    // Check if poll title and description are rendered
    expect(screen.getByText('Team Offsite')).toBeInTheDocument();
    expect(screen.getByText('Planning our annual team offsite event')).toBeInTheDocument();

    // Check if creator info is rendered
    expect(screen.getByText(/Created by Jane Doe/)).toBeInTheDocument();
    expect(screen.getByText(/jane.doe@example.com/)).toBeInTheDocument();
  });

  test('renders best dates section', () => {
    renderWithInertia(<Show poll={mockPoll} participants={mockParticipants} />);

    // Check if Best Dates section is rendered
    expect(screen.getByText('Best Dates')).toBeInTheDocument();

    // Check if date counts are rendered correctly
    expect(screen.getByText('3 Yes')).toBeInTheDocument();
    expect(screen.getByText('2 Yes')).toBeInTheDocument();
  });

  test('renders participants table correctly', () => {
    renderWithInertia(<Show poll={mockPoll} participants={mockParticipants} />);

    // Check if participants table is rendered
    expect(screen.getByText('All Responses')).toBeInTheDocument();

    // Check if participant names are rendered
    expect(screen.getByText('Alice Smith')).toBeInTheDocument();
    expect(screen.getByText('Bob Johnson')).toBeInTheDocument();

    // Check if participant emails are rendered
    expect(screen.getByText('alice.smith@example.com')).toBeInTheDocument();
    expect(screen.getByText('bob.johnson@example.com')).toBeInTheDocument();
  });

  test('handles empty participants list', () => {
    renderWithInertia(<Show poll={mockPoll} participants={[]} />);

    // Check if empty state message is rendered
    expect(screen.getByText('No responses yet')).toBeInTheDocument();
  });

  test('has a working back button', async () => {
    const user = userEvent.setup();
    renderWithInertia(<Show poll={mockPoll} participants={mockParticipants} />);

    const backButton = screen.getByRole('button', { name: /back to polls/i });
    expect(backButton).toBeInTheDocument();

    await user.click(backButton);

    // Check that the link has the correct href
    expect(backButton.closest('a')).toHaveAttribute('href', '/polls');
  });
});
