#!/usr/bin/python3
# -*- coding: utf-8 -*-

import csv
from googletrans import Translator
import sys

if len(sys.argv) < 4:
    print('not enought arguments')
    sys.exit()

in_file_name = sys.argv[1]
out_file_name = sys.argv[2]
colomn_for_trans = int(sys.argv[3])

in_f = open(in_file_name, 'r', newline='')
out_f = open(out_file_name, 'w')
reader = csv.reader(in_f, delimiter=';')
writer = csv.writer(out_f, delimiter=';')

translator = Translator()

i = 1
j = 1
for line in reader:
    print(j)
    translated = translator.translate(line[colomn_for_trans], dest='ru')
    if translated.src == 'ru':
        new_str = line[colomn_for_trans]
    else:
        new_str = translated.text + '__TRANSLATED_' + str(i)
        i += 1
    writer.writerow(line[:colomn_for_trans] + [new_str] + line[colomn_for_trans + 1:])
    j += 1

in_f.close()
out_f.close()
