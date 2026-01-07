// e: keyDown event
export const ArabicToLatinNumbers = (e) => {
  const arabicToLatinMap = {
    '١': ['1', 'Digit1', 49],
    '٢': ['2', 'Digit2', 50],
    '٣': ['3', 'Digit3', 51],
    '٤': ['4', 'Digit4', 52],
    '٥': ['5', 'Digit5', 53],
    '٦': ['6', 'Digit6', 54],
    '٧': ['7', 'Digit7', 55],
    '٨': ['8', 'Digit8', 56],
    '٩': ['9', 'Digit9', 57],
    '٠': ['0', 'Digit0', 48],
  };
  const latinNumber = arabicToLatinMap[e.key];
  if (latinNumber) {
    const handler = Object.keys(e.target).find((key) => key.includes('__reactProps'));
    const onKeyPress = handler && e.target[handler]['onKeyPress'];
    e.preventDefault();
    if (onKeyPress) {
      onKeyPress({ ...e, ...{ key: latinNumber[0], code: latinNumber[1], keyCode: latinNumber[2] }, preventDefault: () => {} });
    } else {
      document.execCommand('insertText', false, latinNumber[0]);
    }
  }
};
