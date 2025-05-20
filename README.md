# Number picker dynamic
Number picker dynamic is a code lock inspired design to use for large numbers and decimals.

## Features
- Turn dials to select each number and decimals
- Auto rounded values to handle decimals fractions
- Dark mode support
- Themed support, with own TextStyle and BoxDecoration support
- Tackles small screens and big screens with different font sizes

|             | Android | iOS | Linux | macOS | Web | Windows |
|-------------|---------|-----|-------|-------|-----|---------|
| **Support** | Yes     | Yes | No    | No    | No  | No      |

## How it looks
Normal mode:

<img src="https://raw.githubusercontent.com/large/numberpicker_dynamic/master/media/1.png"/>

Dark mode:

<img src="https://raw.githubusercontent.com/large/numberpicker_dynamic/master/media/2.png"/>

Large number:

<img src="https://raw.githubusercontent.com/large/numberpicker_dynamic/master/media/3.png"/>

Small number (decimals):

<img src="https://raw.githubusercontent.com/large/numberpicker_dynamic/master/media/4.png"/>

Large number with a lot of decimals (scrollable):

<img src="https://raw.githubusercontent.com/large/numberpicker_dynamic/master/media/5.png"/>

Integrated into other widgets:

<img src="https://raw.githubusercontent.com/large/numberpicker_dynamic/master/media/6.png"/>

<details open="" class="details-reset border rounded-2">
  <summary class="px-3 py-2 border-bottom">
    <svg aria-hidden="true" viewBox="0 0 16 16" version="1.1" data-view-component="true" height="16" width="16" class="octicon octicon-device-camera-video">
    <path fill-rule="evenodd" d="..."></path>
</svg>
    <span aria-label="Number Picker Dynamic video" class="m-1">Number Picker Dynamic live</span>
    <span class="dropdown-caret"></span>
  </summary>

  <video name="" src="https://github.com/user-attachments/assets/c20ae87f-54ad-4a5c-bc02-2fb1c1b89858" data-canonical-src="https://github.com/user-attachments/assets/c20ae87f-54ad-4a5c-bc02-2fb1c1b89858" controls="controls" muted="muted" class="d-block rounded-bottom-2 width-fit" style="max-height:800px;">
    <title>Hest</title>
  </video>
</details>

## Usage

NumberPickerDynamic only require option `onValueChange` callback to be set.

`onValueChange` returns the current value of the number picker.

```dart
NumberPickerDynamic(
  height: 100,
  maxDecimals: 5,
  initValue: 100,
  onValueChange: (value) {
    debugPrint("Value is $value");
  },
),
```

Design is based on the height value and the "bend" you want the dial to be.
If you lower the height bending numbers could make things fit.
Do remember to test on different devices and screen sizes.

## Additional information

Note that TextScale is locked to 40%.
Values above this makes things clip.

Suggestions, PR or any contributions are welcome!
Find source on https://github.com/large/numberpicker_dynamic

## License
The MIT License (MIT)

Copyright (c) 2025 Lars Werner

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
Credit the original creator Lars Werner for the design.

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
