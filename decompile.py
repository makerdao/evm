#! /usr/bin/python3

import sys

file = open(sys.argv[1])
has_constructor = False
if len(sys.argv) > 2 and sys.argv[2] == 'deployment':
    has_constructor = True

code = file.read()
if code[:2] == '0x':
    code = code[2:]
if code[-1:] == '\n':
    code = code[:-1]
bytes = [code[i:i+2] for i in range(len(code)) if i % 2 == 0]

constructor = []
lines = []
length = 1
in_constructor = has_constructor
for i, byte in enumerate(bytes):
    if length == 1:
        if byte[0] in ['6', '7']:
            length = int(byte, 16) - 0x60 + 2
        if in_constructor:
            constructor.append([ byte ])
        else:
            lines.append([ byte ])
        if byte == 'f3' and bytes[i + 1] != 'fe':
            in_constructor = False
        elif byte == 'fe':
            in_constructor = False
    else:
        if in_constructor:
            constructor[-1].append(byte)
        else:
            lines[-1].append(byte)
        length -= 1

jumpdests = []
for i, bytes in enumerate(lines):
    if bytes[0] == '5b':
        length = 0
        for bytes in lines[:i]:
            length += len(bytes)
        location = hex(length)[2:]
        if len(location) % 2 != 0:
            location = '0' + location
        elements = [location[i:i+2] for i in range(len(location)) if i % 2 == 0]
        if len(elements) > 2:
            raise ValueError('3-byte jumpdests not supported')
        jumpdests.append(elements)

if has_constructor:
    print('# constructor')
    for bytes in constructor:
        line = ' '.join(bytes)
        print(line)

print('\n\n\n')

index = 0
print('# start')
for bytes in lines:
    line = ' '.join(bytes)
    if line == '5b':
        two_byte = jumpdests[index]
        if len(jumpdests[index]) == 1:
            two_byte = ['00', *jumpdests[index]]
        print('# ' + ''.join(two_byte) + '\n' + line)
        index += 1
    elif line in ['56', 'f3', 'fd']:
        print(line)
        print('\n')
    elif bytes[0] in ['60', '61']:
        value = bytes[1:]
        for jumpdest in jumpdests:
            two_byte = jumpdest
            if len(jumpdest) == 1:
                two_byte = ['00', *jumpdest]
            if value in [jumpdest, two_byte]:
                print('61 -> ' + ''.join(two_byte) + '\t// ' + line)
                break
        else:
            print(line)
    else:
        print(line)
