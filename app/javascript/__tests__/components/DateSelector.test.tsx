import { render, screen } from '@testing-library/react';

import { DateSelector } from '@/components/DateSelector';

describe('DateSelector Component', () => {
  const mockOnChange = vi.fn();

  beforeEach(() => {
    mockOnChange.mockClear();
  });

  test('renders correctly with empty dates', () => {
    render(<DateSelector onChange={mockOnChange} initialDates={[]} />);

    // Check if selected dates section is rendered
    expect(screen.getByText('Selected Dates')).toBeInTheDocument();
    expect(screen.getByText('No dates selected. Click on the calendar to select dates for your event.')).toBeInTheDocument();
  });

  test('renders correctly with initial dates', () => {
    const initialDates = [
      new Date(2025, 5, 15), // June 15, 2025
      new Date(2025, 5, 22), // June 22, 2025
    ];

    render(<DateSelector onChange={mockOnChange} initialDates={initialDates} />);

    // Check if both dates are displayed in the selected dates section
    expect(screen.getByText('Sunday, June 15, 2025')).toBeInTheDocument();
    expect(screen.getByText('Sunday, June 22, 2025')).toBeInTheDocument();
  });

  test('renders with error state', () => {
    render(<DateSelector onChange={mockOnChange} initialDates={[]} hasError={true} />);

    // Check if the component has error styling (border-destructive class)
    const selectedDatesContainer = screen.getByText('Selected Dates').closest('[class*="border-destructive"]');
    expect(selectedDatesContainer).toBeInTheDocument();
  });

  test('shows selected dates', () => {
    const initialDates = [
      new Date(2025, 5, 15), // June 15, 2025
    ];

    render(<DateSelector onChange={mockOnChange} initialDates={initialDates} />);

    // Check if selected dates are shown in the list
    const dateFormat = new Intl.DateTimeFormat('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });

    const formattedDate = dateFormat.format(initialDates[0]);
    expect(screen.getByText(formattedDate)).toBeInTheDocument();
  });
});
