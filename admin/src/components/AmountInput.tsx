import type { KeyboardEvent } from "react";
import { backspace, formatMoney, pushDigit } from "../money";

interface Props {
  minor: number;
  onChange: (minor: number) => void;
  autoFocus?: boolean;
}

// Ввод суммы как на кассовой клавиатуре мобильного приложения: каждая
// нажатая цифра становится новым младшим разрядом, последние два —
// teňňe. Редактирование курсором не предусмотрено — так же, как на
// мобильной клавиатуре с фиксированной запятой.
export function AmountInput({ minor, onChange, autoFocus }: Props) {
  function handleKeyDown(e: KeyboardEvent<HTMLInputElement>) {
    e.preventDefault();
    if (e.key >= "0" && e.key <= "9") {
      onChange(pushDigit(minor, e.key));
    } else if (e.key === "Backspace" || e.key === "Delete") {
      onChange(backspace(minor));
    }
  }

  return (
    <span className="amount-input">
      <input
        className="amount-input-field"
        inputMode="numeric"
        value={formatMoney(minor)}
        onChange={() => {}}
        onKeyDown={handleKeyDown}
        autoFocus={autoFocus}
      />
      <span className="amount-input-suffix">TMT</span>
    </span>
  );
}
