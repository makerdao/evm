#! /usr/bin/python3

import sys, re, functools

def clean(lines):
    result = []
    for line in lines:
        clean = re.sub('\s*//.*', '', line)
        no_newline = re.sub('\n', '', clean)
        if len(no_newline) > 1:
            result.append(no_newline)
    return result

def tokenize(lines):
    result = []
    clean_lines = clean(lines)
    for line in clean_lines:
        no_tag_defs = re.sub('#.*', '', line)
        no_tag_eqs = re.sub(':.*', ':: ::', no_tag_defs)
        no_tag_calls = re.sub('->.*', '-> ->', no_tag_eqs)
        if len(no_tag_calls) > 1:
            code = re.sub('[^a-f0-9->:]*', '', no_tag_calls)
            opcodes = [code[i:i+2] for i in range(0, len(code), 2)]
            result += opcodes
    return result

def get_tags(dirty_lines):
    tags = {}
    lines = clean(dirty_lines)
    for i, line in enumerate(lines):
        if '#' in line:
            name = re.sub('.*# ', '', line)
            pre_code = lines[: i + 1]
            tokens = tokenize(pre_code)
            location = len(tokens)
            tags[name] = location
    return tags

def replace_tags(lines, tags):
    result = []
    contract = clean(lines)
    for line in contract:
        new_line = line
        if '->' in line:
            tag_call = re.sub('.*-> ', '', line)
            location = tags[tag_call] - tags['start']
            hex_location = hex(location)[2:].rjust(4, '0')
            escaped_call = tag_call.replace('(', '\(').replace(')', '\)') \
                .replace('[', '\[').replace(']', '\]')
            new_line = re.sub('-> ' + escaped_call, hex_location, line)
        elif ':' in line:
            equation = line[line.find(':') + 2 :]
            symbols = re.split(' - ', equation)
            locations = []
            for symbol in symbols:
                location = tags[symbol]
                locations.append(location)
            location = functools.reduce(lambda a,b: a - b, locations)
            hex_location = hex(location)[2:].rjust(4, '0')
            new_line = re.sub(':.*', hex_location, line)
        result.append(new_line)
    return result

file = open(sys.argv[1])
lines = file.readlines()
tags = get_tags(lines)
code = replace_tags(lines, tags)
for line in code:
    sys.stdout.write(line + '\n')
