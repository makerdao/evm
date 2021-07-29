#! /usr/bin/python3

file = open('src/erc20.bin')
code = file.read()[2:-1]
bytes = [code[i:i+2] for i in range(len(code)) if i % 2 == 0]

lines = []
length = 1
for byte in bytes:
    if length == 1:
        if byte[0] in ['6', '7']:
            length = int(byte, 16) - 0x60 + 2
        lines.append([byte])
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

index = 0
print('# start')
for bytes in lines:
    line = ' '.join(bytes)
    if (line == '5b'):
        two_byte = jumpdests[index]
        if len(jumpdests[index]) == 1:
            two_byte = ['00', *jumpdests[index]]
        print('\n')
        print(line + ' # ' + ''.join(two_byte))
        index += 1
    elif bytes[0] in ['60', '61']:
        value = bytes[1:]
        for jumpdest in jumpdests:
            two_byte = jumpdest
            if len(jumpdest) == 1:
                two_byte = ['00', *jumpdest]
            if value in [jumpdest, two_byte]:
                print('61 -> ' + ''.join(two_byte))
                break
        else:
            print(line)
    else:
        print(line)
