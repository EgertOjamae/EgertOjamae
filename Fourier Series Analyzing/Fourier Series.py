import sys
import numpy as np
from PyQt5.QtWidgets import QWidget, QApplication
from PyQt5.QtGui import QPainter, QColor, QFont, QPen, QPalette
from PyQt5.QtCore import QPointF, Qt
from pyqtgraph.Qt import QtGui, QtCore
from collections import namedtuple

Phasor = namedtuple('Phasor', 'frequency magnitude phase')  # Ühe faasori omadused


class PhasorSumVisualizer(QWidget):

    def __init__(self, parent, CIRCLE_START_X=250, CIRCLE_START_Y=250) -> None:
        super().__init__(parent=parent)
        self.G_SCALER = parent.G_SCALER
        self.CIRCLE_START_X = CIRCLE_START_X
        self.CIRCLE_START_Y = CIRCLE_START_Y

        # Need on x,y stardipositsioonid, kuhu hakatakse igal uuendamisel liitma
        #   sageduskomponentide avaldatavat x,y positsioonide nihet.
        self.x_pos = CIRCLE_START_X
        self.y_pos = CIRCLE_START_Y
        self.ROTATION_OFFSET = 0  # Faasinihe kõikidele sageduskomponentidele
        self.phasors = []  # Järjend faasoritest, mille elemendid on kujul namedtuple("frequency", "magnitude")
        self.circles = []  # Järjend faasorite ringidest, mille elemendid on kujul [[x, y], raadius]

    def paint(self, qp):
        """
        See funktsioon joonistab faasorid praegusel ajahetkel.

        Sisendid:
        qp: QPainter objekt, millega saab joonistada

        Vaata https://doc.qt.io/qt-5/qpainter.html#drawEllipse-2
          ja  https://doc.qt.io/qt-5/qpainter.html#drawLine-2
        """
        # Joonista algpunkt
        qp.setPen(QPen(Qt.red, 3))
        qp.drawEllipse(self.CIRCLE_START_X, self.CIRCLE_START_Y, 3, 3)
        # Ülesanne 1:
        # Joonista ühe faasori ring ja vektor
        # TODO
        '''
        if len(self.circles) == 0:
            ringX,ringY = 0, 0
            raadius = 0
        else:
            ring = self.circles[0]
            ringX = ring[0][0]
            ringY = ring[0][1]
            raadius = ring[1]

        qp.setPen(QPen(Qt.blue, 3))
        qp.drawLine(ringX, ringY, self.x_pos, self.y_pos)  #joone vasakpoolne punkt ning parempoolne punkt
        qp.drawEllipse(QPointF(self.CIRCLE_START_X, self.CIRCLE_START_Y), raadius, raadius)
        '''
        # Ülesanne 2:
        # Joonista iga faasori ring ja vektor
        # TODO
        for i in range(len(self.circles)):
            xKoordinaat = self.circles[i][0][0]
            yKoordinaat = self.circles[i][0][1]
            raadius = self.circles[i][1]
            qp.setPen(QPen(Qt.blue, 3))
            #print(len(self.circles))
            if i == len(self.circles) - 1:
                qp.drawLine(int(xKoordinaat), int(yKoordinaat), int(self.x_pos), int(self.y_pos))  # joone vasakpoolne punkt ning parempoolne punkt
            else:
                qp.drawLine(int(xKoordinaat), int(yKoordinaat), int(self.circles[i + 1][0][0]), int(self.circles[i + 1][0][1]))
            qp.drawEllipse(QPointF(xKoordinaat, yKoordinaat), raadius, raadius)


    def calculatePhasors(self, angle):
        """
        See funktsioon arvutab välja faasorite väärtused ajahetkel n ja summeerib nende mõju.

        Sisendid:
        n: ajahetk/nurk radiaanides

        """
        self.x_pos = self.CIRCLE_START_X
        self.y_pos = self.CIRCLE_START_Y
        self.circles.clear()
        # Ülesanne 1:
        # Võta järjendist self.phasors esimene element ja arvuta selle koordinaadid
        # Salvesta ringi keskpunkt ja raadius järjendisse self.circles
        # Korruta eelnevalt ka G_SCALERiga läbi, et faasor visuaalselt suurem paistaks
        # TODO
        '''
        elements = self.phasors[0]
        sagedus = elements.frequency
        magnituud = elements.magnitude

        #Vastavalt valemile arvutada koordinaadid
        xKoordinaat = magnituud * np.cos(angle) * self.G_SCALER
        yKoordinaat = magnituud * np.sin(angle) * self.G_SCALER
        x, y  = self.CIRCLE_START_X, self.CIRCLE_START_Y
        self.circles.append(([x, y], magnituud * self.G_SCALER))

        #Liidame mõju juurde
        self.x_pos = self.CIRCLE_START_X + xKoordinaat
        self.y_pos = self.CIRCLE_START_Y - yKoordinaat
        '''


        # Ülesanne 2:
        # Käi läbi iga faasor ja arvuta selle mõju algpositsioonile
        # Salvesta lõplikud koordinaadid väljadesse self.x_pos ja self.y_pos (korruta enne G_SCALER-iga läbi)
        # Salvesta self.circles järjendisse kõikide faasorite keskpunktide koordinaadid ja raadiused
        # TODO
        elements = self.phasors
        loendur = 0
        for i in elements:
            magnituud = i.magnitude
            sagedus = i.frequency


            #Vastavalt valemile arvutame koordinaadid
            xKoordinaat = magnituud * np.cos(sagedus * angle + i.phase + self.ROTATION_OFFSET) * self.G_SCALER #nurk tuleb sagedusega läbi korrutada
            yKoordinaat = magnituud * np.sin(sagedus * angle + i.phase + self.ROTATION_OFFSET) * self.G_SCALER
            self.circles.append(([self.x_pos, self.y_pos], magnituud * self.G_SCALER))

            if loendur > 0:
                self.x_pos = self.circles[loendur][0][0] + xKoordinaat
                self.y_pos = self.circles[loendur][0][1] - yKoordinaat

            else:
                self.x_pos = self.CIRCLE_START_X + xKoordinaat
                self.y_pos = self.CIRCLE_START_Y - yKoordinaat
            loendur += 1




class Main(QWidget):
    WINDOW_WIDTH = 1080
    WINDOW_HEIGHT = 480
    G_SCALER = 50

    WAVE_MAX_LENGTH = 5000  # Maksimaalne arv lõppsignaali punkte, mida kuvame
    X_POS_INCREMENT = 2.5  # x-telje nihutamise samm
    X_POS_OFFSET = 500  # Lõppsignaali kaugus faasoritest x-teljel

    DELTA_ANGLE = 0.1  # Diskreetimise samm
    nr_of_terms = 1  # Mitu sageduskomponenti välja arvutame
    current_angle = 0  # Praegune ajahetk

    path = []

    def __init__(self) -> None:
        super().__init__()
        self.initUI()
        self.psv = PhasorSumVisualizer(self)

    def initUI(self):
        self.setGeometry(300, 300, self.WINDOW_WIDTH, self.WINDOW_HEIGHT)
        self.setWindowTitle('Faasorid')
        # set black background
        pal = self.palette()
        pal.setColor(QPalette.Background, Qt.black)
        self.setAutoFillBackground(True)
        self.setPalette(pal)
        self.show()

    def paintEvent(self, e):
        """
        See funktsioon joonistab faasorid ja nende põhjal arvutatud signaali.
        """
        qp = QPainter()
        qp.begin(self)
        # Joonista faasorid
        self.psv.paint(qp)
        qp.setPen(QPen(Qt.red, 3))
        # Joonista kogu seni arvutatud signaal
        self.drawPath(qp)
        # Joonista joon faasorite summa tipust nihutatud lõppsignaalini
        # TODO
        qp.drawLine(int(self.psv.x_pos), int(self.psv.y_pos),int(self.X_POS_OFFSET), int(self.psv.y_pos)) #faasorit ja signaali ühendav joon

        qp.end()

    def update(self):
        self.psv.phasors.clear()
        self.current_angle += self.DELTA_ANGLE  # Liigutame aega edasi
        # 1. Ülesanne
        # Sisesta järjendisse self.psv.phasors üks namedtuple tüüpi faasor sagedusega 1 ja magnituudiga 1
        # TODO
        Phasor.frequency = 1
        Phasor.magnitude = 1
        self.psv.phasors.append(Phasor)

        # 2. Ülesanne
        # Arvuta nr_of_terms arv faasoreid ja lisa järjendisse self.psv.phasors
        # TODO
        for i in range(self.nr_of_terms):
            i += 1
            ruutSignaal = square_wave(i)
            if ruutSignaal: #kui square_wave seest ei saada None, siis appendime
                self.psv.phasors.append(ruutSignaal)

        self.psv.calculatePhasors(self.current_angle)
        # 2. Ülesanne
        # Lisa välja arvutatud punkt väljundisse
        # TODO
        self.add_point([self.X_POS_OFFSET, self.psv.y_pos]) #ülesaneded 1 ja 2
        #self.add_point([self.X_POS_OFFSET + self.fourier_x + self.ROTATION_OFFSET, self.psv.y_pos + self.fourier_y + self.ROTATION_OFFSET]) # yl4 ?????

        super().update()  # Trigger paintEvent

    def keyPressEvent(self, event):
        key = event.key()
        if key == Qt.Key_Up:
            self.nr_of_terms += 1
        elif key == Qt.Key_Down:
            self.nr_of_terms -= 1



    def add_point(self, point):
        """
        See funktsioon lisab antud punkti lõppsignaalile
        """
        qpoint = QPointF(point[0], point[1])
        self.path = [QPointF(point.x() + self.X_POS_INCREMENT, point.y()) for point in self.path]
        self.path.insert(0, qpoint)
        self.path = self.path[:self.WAVE_MAX_LENGTH]

    def drawPath(self, qp):
        """
        See funktsioon joonistab jooned seni arvutatud lõppsignaali punktide vahele
        """
        for i, point in enumerate(self.path):
            if i != len(self.path) - 1:
                qp.drawLine(point, self.path[i + 1])


def square_wave(term):
    """
    See funktsioon võtab sisendiks, mitmendat ruutsignaali järku praegu arvutatakse
    ning tagastab sellele järgule vastava faasori.
    https://en.wikipedia.org/wiki/Fourier_series#Convergence
    https://www.mathsisfun.com/calculus/fourier-series.html

    Sisendid:
    term: mitmendat ruutsignaali sinusoidaalset komponenti arvutatakse

    Tagastab:
    phasor: namedtuple, mille sisuks on faasori sagedus ja magnituud
    """
    if term <= 1:
       return None

    Phasor.frequency = term * 2 - 1
    Phasor.magnitude = 1 / Phasor.frequency
    Phasor.phase = 0
    return Phasor


def main():
    app = QApplication(sys.argv)
    main = Main()

    timer = QtCore.QTimer()
    timer.timeout.connect(main.update)
    timer.start(15)
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
