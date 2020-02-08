#!/usr/bin/python3
# -*- coding: utf-8 -*-

import csv
import sys
from yandex_translate import YandexTranslate


if len(sys.argv) < 4:
    print('not enought arguments')
    sys.exit()

in_file_name = sys.argv[1]
out_file_name = sys.argv[2]
colomn_for_trans = int(sys.argv[3])

in_f = open(in_file_name, 'r', newline='')
out_f = open(out_file_name, 'w', newline='')
reader = csv.reader(in_f, delimiter=';', quotechar='"', lineterminator='\r\n')
writer = csv.writer(out_f, delimiter=';', quotechar='"', lineterminator='\r\n')

translator = YandexTranslate('trnsl.1.1.20191008T013416Z.1a20ea9c1d54448d.86c89b2c8f3ec5d12030d9d5f21d2b97e19b69bc')

i = 1
j = 1
for line in reader:
    if j % 10 == 0:
        print(j)
    j += 1
    if line[colomn_for_trans] == '':
        writer.writerow(line[:colomn_for_trans] + [''] + line[colomn_for_trans + 1:])
        continue

    translated = translator.translate(line[colomn_for_trans], 'ru')['text'][0]
    if translated == line[colomn_for_trans]:
        new_str = line[colomn_for_trans]
    else:
        new_str = translated + '__TRANSLATED_' + str(i)
        i += 1
    writer.writerow(line[:colomn_for_trans] + [new_str] + line[colomn_for_trans + 1:])

in_f.close()
out_f.close()
