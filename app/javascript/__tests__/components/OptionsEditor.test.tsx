import { fireEvent, render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useState } from 'react';

import { OptionsEditor, type OptionInput } from '@/components/OptionsEditor';

function Harness({ initial, onChange }: { initial: OptionInput[]; onChange: (o: OptionInput[]) => void }) {
  const [value, setValue] = useState(initial);

  return (
    <OptionsEditor
      value={value}
      onChange={next => {
        setValue(next);
        onChange(next);
      }}
    />
  );
}

describe('OptionsEditor', () => {
  test('shows an empty state', () => {
    render(<OptionsEditor value={[]} onChange={vi.fn()} />);

    expect(screen.getByText(/No dates selected/)).toBeInTheDocument();
  });

  test('lists picked days as all-day options', () => {
    render(
      <OptionsEditor
        value={[{ date: '2030-06-15', time: '', duration_minutes: 1440 }]}
        onChange={vi.fn()}
      />
    );

    const day = screen.getByTestId('day-2030-06-15');
    expect(day).toHaveTextContent('Saturday, June 15, 2030');
    expect(within(day).getByText('All day')).toBeInTheDocument();
  });

  test('"Add time" turns an all-day option into a time slot, then adds more', async () => {
    const onChange = vi.fn();
    render(<Harness initial={[{ date: '2030-06-15', time: '', duration_minutes: 1440 }]} onChange={onChange} />);

    await userEvent.click(screen.getByRole('button', { name: /add time/i }));
    expect(onChange).toHaveBeenLastCalledWith([{ date: '2030-06-15', time: '18:00', duration_minutes: 60 }]);

    await userEvent.click(screen.getByRole('button', { name: /add time/i }));
    expect(onChange).toHaveBeenLastCalledWith([
      { date: '2030-06-15', time: '12:00', duration_minutes: 60 },
      { date: '2030-06-15', time: '18:00', duration_minutes: 60 },
    ]);
  });

  test('changing the time and duration updates the slot', () => {
    const onChange = vi.fn();
    render(<Harness initial={[{ date: '2030-06-15', time: '18:00', duration_minutes: 60 }]} onChange={onChange} />);

    fireEvent.change(screen.getByLabelText('Start time'), { target: { value: '19:30' } });
    expect(onChange).toHaveBeenLastCalledWith([{ date: '2030-06-15', time: '19:30', duration_minutes: 60 }]);

    fireEvent.change(screen.getByLabelText('Duration'), { target: { value: '120' } });
    expect(onChange).toHaveBeenLastCalledWith([{ date: '2030-06-15', time: '19:30', duration_minutes: 120 }]);
  });

  test('removing the last slot of a day removes the day', async () => {
    const onChange = vi.fn();
    render(<Harness initial={[{ date: '2030-06-15', time: '', duration_minutes: 1440 }]} onChange={onChange} />);

    await userEvent.click(screen.getByRole('button', { name: 'Remove' }));

    expect(onChange).toHaveBeenLastCalledWith([]);
    expect(screen.getByText(/No dates selected/)).toBeInTheDocument();
  });
});
