from turtle import bgcolor
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.widgets import Button as Button
from matplotlib import text
import os
import cv2
import numpy as np
from tkinter import filedialog, Tk
from bilinear_interpolation import *


class Interface:

    # Class Variable
    rows = 1
    columns = 3
    bg_color = 'whitesmoke'
    lines_color = 'black'
    sq_color = 'red'
    bn1_color = 'darkgrey'
    bn2_color = 'darkturquoise'
    hl_color = 'aqua'
    path = None
    pic = None
    visible = True
    full_pixels = 390
    div_pixels = 97
    ticks = range(0, full_pixels, div_pixels)[1:-1]
    tiles = []
    index = 0
    square_offset = 5
    square_size = 88

    def __init__(self):
        # plt.close()
        self.create_figure()

    def create_tiles(self):
        for y1 in range(0, self.full_pixels-2, self.div_pixels):
            for x1 in range(0, self.full_pixels-2, self.div_pixels):
                x2 = x1 + self.div_pixels
                y2 = y1 + self.div_pixels
                self.tiles.append([x1, y1, x2, y2])
        # print(self.tiles)

    def create_figure(self):
        # create figure
        self.fig, axs = plt.subplots(
            nrows=self.rows, ncols=self.columns, figsize=(14, 6))
        self.fig.patch.set_facecolor('snow')
        self.fig.canvas.set_window_title(
            'Project 1 - Arquitectura de Computadores 1')
        self.fig.set_facecolor(self.bg_color)
        self.fig.suptitle('Bilinear Interpolation', fontweight="bold")
        self.fig.canvas.mpl_connect('button_press_event', self.on_press)
        plt.subplots_adjust(top=0.85, bottom=0.2)
        self.ax1 = axs[0]
        self.ax2 = axs[1]
        self.ax3 = axs[2]

        # SUBPLOTS CONFIGUTATION
        # original image, settings
        self.ax1.set(title="original")
        self.ax1.patch.set_facecolor(self.bg_color)
        self.ax1.set_xlim(left=0, right=388)
        self.ax1.set_ylim(bottom=388, top=0)
        self.ax1.axes.set_xticks(self.ticks)
        self.ax1.axes.set_yticks(self.ticks)
        self.ax1.grid(alpha=1, color=self.lines_color)
        plt.setp(self.ax1.spines.values(), linewidth=2, color=self.lines_color)

        # crop image, settings
        self.ax2.set(title="cropped")
        self.ax2.patch.set_facecolor(self.bg_color)
        self.ax2.set_axis_off()
        # interpolated image, settings
        self.ax3.set(title="interpolated")
        self.ax3.patch.set_facecolor(self.bg_color)
        self.ax3.set_axis_off()

        # square
        x = y = 20
        self.square = patches.Rectangle(
            (x, y), self.square_size, self.square_size, linewidth=4, edgecolor=self.sq_color, facecolor='none')
        self.ax1.add_patch(self.square)

        # visibility
        self.toggle_visibility()

        # BUTTONS
        # add upload button
        ax_button = plt.axes([0.40, 0.03, 0.1, 0.075])
        bn_load = Button(ax_button, 'Upload',
                         color=self.bn1_color, hovercolor=self.hl_color)
        bn_load.on_clicked(self.load_image)
        # add apply button
        ax_apply = plt.axes([0.505, 0.03, 0.1, 0.075])
        bn_apply = Button(ax_apply, 'Apply',
                          color=self.bn2_color, hovercolor=self.hl_color)
        bn_apply.on_clicked(self.apply_algorithm)

        plt.show()

    # Toggle visibility of subplot 1 stuff

    def toggle_visibility(self):
        self.ax1.get_xaxis().set_visible(not self.visible)
        self.ax1.get_yaxis().set_visible(not self.visible)
        self.ax1.spines["top"].set_visible(not self.visible)
        self.ax1.spines["bottom"].set_visible(not self.visible)
        self.ax1.spines["right"].set_visible(not self.visible)
        self.ax1.spines["left"].set_visible(not self.visible)
        self.square.set_visible(not self.visible)
        self.visible = not self.visible
        plt.draw()

    # Move Rectangle

    def on_press(self, event):
        if (not self.visible):
            return
        if event.inaxes in [self.ax1]:

            self.index = self.index+1 if (self.index < 15) else 0
            x, y = self.tiles[self.index][0], self.tiles[self.index][1]
            self.square.set_xy((x+self.square_offset, y+self.square_offset))
            self.fig.canvas.draw()

    # Load Image
    def load_image(self, event):
        Tk().withdraw()
        self.path = filedialog.askopenfilename(
            initialdir=os.path.join(os.getcwd(), 'imgs'),
            title="Select file",
            filetypes=(("", "*.jpg"), ("","*.png"),("all files", "*.*")))
        if (self.path is None): return
        self.pic = self.rgb2gray(cv2.imread(self.path))
        self.create_tiles()
        self.square.set_xy((self.square_offset, self.square_offset))
        self.index = 0
        self.ax1.imshow(self.pic, cmap=plt.get_cmap('gray'))
        if (not self.visible):
            self.toggle_visibility()
        # print ("\nUploaded:",self.path)

    # Apply algorithm
    def apply_algorithm(self, event):
        if (self.path == None):
            return

        box = self.tiles[self.index]
        crop_image = self.pic[box[1]:box[3], box[0]:box[2]]

        if (crop_image is None):
            return

        # Write to txt.
        InterpolatedImage = algorithm(crop_image.tolist(), crop_image.shape[0])
        
        # InterpolatedImage = algorithm_revision();
        
        print("Output dimensions:", InterpolatedImage.shape)
        self.ax2.imshow(crop_image, cmap=plt.get_cmap('gray'))
        self.ax3.imshow(InterpolatedImage, cmap=plt.get_cmap('gray'))

    # RGB TO GRAY - 3dim to 2dim

    def rgb2gray(self, rgb):
        return np.dot(rgb[..., : 3], [1, 0, 0])


interface = Interface()
