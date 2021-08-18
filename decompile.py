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
constructor_length = 0
for i, byte in enumerate(bytes):
    if length == 1:
        if byte[0] in ['6', '7']:
            length = int(byte, 16) - 0x60 + 2
        if in_constructor:
            constructor.append([ byte ])
        else:
            lines.append([ byte ])
        if (
                in_constructor
                and ((byte == 'f3' and bytes[i + 1] != 'fe') or byte == 'fe')
        ):
            in_constructor = False
            constructor_length = i + 1
    else:
        if in_constructor:
            constructor[-1].append(byte)
        else:
            lines[-1].append(byte)
        length -= 1

def get_jumpdests(lines):
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
    return jumpdests

def process(lines, constructor=False):
    jumpdests = get_jumpdests(lines)
    index = 0
    for i, bytes in enumerate(lines):
        line = ' '.join(bytes)
        if line == '5b':
            two_byte = jumpdests[index]
            if len(jumpdests[index]) == 1:
                two_byte = ['00', *jumpdests[index]]
            if constructor:
                print('# c-' + ''.join(two_byte) + '\n' + line)
            else:
                print('# ' + ''.join(two_byte) + '\n' + line)
            index += 1
        elif line in ['56', 'f3', 'fd', '00']:
            print(line)
            print('\n')
        elif line == 'fe' and lines[i - 1] == ['00'] and lines[i + 1] == ['a1']:
            print(line)
            print('\n')
            print(''.join([''.join(line) for line in lines[i + 1:]]))
            break
        elif bytes[0] in ['60', '61']:
            value = bytes[1:]
            for jumpdest in jumpdests:
                two_byte = jumpdest
                if len(jumpdest) == 1:
                    two_byte = ['00', *jumpdest]
                if value in [jumpdest, two_byte]:
                    if constructor:
                        print('61 : c-' + ''.join(two_byte))
                    else:
                        print('61 -> ' + ''.join(two_byte))
                    break
            else:
                print(line)
        else:
            print(line)


if has_constructor:
    print('# constructor')
    process(constructor, True)
    print('\n\n\n')
print('# start-' + hex(constructor_length)[2:])
process(lines)
print('# end-' + hex(len(bytes) - constructor_length)[2:])
print('// total length: ' + hex(len(bytes)))
