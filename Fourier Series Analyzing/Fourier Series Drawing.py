#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import numpy as np
import pygame
from drawing_functions import draw_path, add_point
from sample_signals import signal3, signal4
signal4 = signal4[:int(len(signal4)/3)]
signal3 = signal3[:int(len(signal3)/3)]

def dft_complex(input_signal):
    input_signal = np.asarray(input_signal)
    N = input_signal.size
    n = np.arange(N)
    k = n.reshape((N, 1))
    e = np.exp(-2j * np.pi * k * n / N)
    return np.dot(e, input_signal) / N

#taust, nurk, esimene asukoht, nurkade juurde liidetav, sisendlist
def draw_epicycles(canvas, current_angle, x_pos, y_pos, rotation_offset, fourier):
    for k in range(len(fourier)):
        faas = np.arctan2(fourier[k][0].imag, fourier[k][0].real) #et arvutada x ja y kordinaati on vaja faasi ja magnituudi
        magnitude = np.sqrt(fourier[k][0].real ** 2 + fourier[k][0].imag ** 2)
        x_first = x_pos #eelmine koordinaat-paar
        y_first = y_pos
        x_pos += magnitude * np.cos(fourier[k][1] * current_angle + faas + rotation_offset) #uus koordinaat-paar
        y_pos += magnitude * np.sin(fourier[k][1] * current_angle + faas + rotation_offset)
        pygame.draw.circle(canvas, (255, 0, 255), (int(x_first), int(y_first)), int(abs((magnitude + 1))), 1) #joonistatakse ringid , magnitud = joonepikkus, +1 sest ei saa olla 0, 1=laius
        pygame.draw.line(canvas, (255, 255, 255), (int(x_first), int(y_first)), (int(x_pos), int(y_pos)))#joonistatakse jooned ringide vahele
    return x_pos, y_pos


def main():
    path = []
    WINDOW_WIDTH = 1080
    WINDOW_HEIGHT = 720

    COLOUR_BLACK = (0, 0, 0)

    WAVE_MAX_LENGTH = 1000
    X_POS_INCREMENT = 0
    #joone nurgad
    current_angle = 0

    # Initsialiseeri pygame
    pygame.init()
    pygame.display.set_caption("Viies ülesanne")
    background = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT))

    # See muutuja kontrollib peatsüklit
    running = True

    xy_list = []
    print(len(signal3))
    print(len(signal4))
    #sellega teeme ühe kompleksarvulise sisendsignaali, reaalosa on x kordinaat ja imaginaarosa on y kordinaat
    for i in range(len(signal3)):
        xy_list.append(signal4[i] * 1j + signal3[i])

    fourier_complex = dft_complex(xy_list)
    fourier_with_freq = []
    #lisame listi kompleksarvulise sageduskomponendi ja tema täisarvulise kuju, sortimisel kasutatakse ära indexit(x)
    for x in range(len(xy_list)):
        fourier_with_freq.append((fourier_complex[x], x))

    fourier_with_freq = sorted(fourier_with_freq, key=lambda tup: np.abs(tup[0]), reverse=True)
    #et iga järgmise iteratsiooniga joonistatakse õige nurga all joon
    DELTA_ANGLE = 2 * np.pi / len(fourier_with_freq)
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
        x_koordinaat, y_koordinaat = draw_epicycles(background, current_angle, 540, 350, 0, fourier_with_freq)
        # Joonista terve signaal
        #lisame path listi koordinaadid, x_pos_increment = 0 et pilt ei liiguks, wave_max_lenght = kui palju elemente hoiame meeles
        path = add_point(path, (int(x_koordinaat), int(y_koordinaat)), X_POS_INCREMENT, WAVE_MAX_LENGTH)
        draw_path(background, path, (255,0,0))

        #pygame.display.flip()
        pygame.display.update()
        background.fill(COLOUR_BLACK)
        current_angle += DELTA_ANGLE

        # See hävitab pygame protsessi, ilma selleta jääb pygame taustal tööle
    pygame.quit()
    sys.exit(0)


if __name__ == "__main__":
    main()