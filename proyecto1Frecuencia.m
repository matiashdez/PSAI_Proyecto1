clear all
close all
clc

[filename, pathname] = uigetfile({'*.jpg;*.png;*.tif', 'Imágenes (*.jpg, *.png, *.tif)'}, 'Selecciona una imagen');
if isequal(filename, 0)
   disp('No se seleccionó ninguna imagen');
   return;
end

Caracterization = im2double(imread(fullfile(pathname, filename)));
if size(Caracterization, 3) == 3  % Convertir a gris si es RGB
    Caracterization = rgb2gray(Caracterization);
end

FourierT = fft2(Caracterization);
FourierTshift = fftshift(FourierT);

magnitudeSpectrum = log(1 + abs(FourierTshift));
figure;
imshow(magnitudeSpectrum, []);
title('Espectro de Magnitud de la Imagen');