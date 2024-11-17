clear all;
close all;
clc;

% Selección de archivo
[filename, pathname] = uigetfile({'*.jpg;*.png;*.tif', 'Imágenes (*.jpg, *.png, *.tif)'}, 'Selecciona una imagen');
if isequal(filename, 0)
   disp('No se seleccionó ninguna imagen');
   return;
end

% Leer la imagen y convertir a double
Caracterization = im2double(imread(fullfile(pathname, filename)));

% Convertir a escala de grises si es una imagen RGB
if size(Caracterization, 3) == 3
    Caracterization = rgb2gray(Caracterization);
end

% Histograma normalizado y CDF
hnorm = imhist(Caracterization)./numel(Caracterization);
cdf = cumsum(hnorm);

% Ecualización de la imagen
ecualizada = histeq(Caracterization, 256);

% Crear figura para mostrar resultados
figure;

% Imagen original
subplot(3, 3, 1);
imshow(Caracterization);
title('Imagen Original');

% Histograma de la imagen original
subplot(3, 3, 2);
imhist(Caracterization);
title('Histograma Original');

% CDF de la imagen original
subplot(3, 3, 3);
plot(cdf);
title('CDF de la Imagen Original');
xlabel('Intensidad de píxeles');
ylabel('CDF');

% Imagen ecualizada
subplot(3, 3, 4);
imshow(ecualizada);
title('Imagen Ecualizada');

% Histograma de la imagen ecualizada
subplot(3, 3, 5);
imhist(ecualizada);
title('Histograma Ecualizado');

% CDF de la imagen ecualizada
cdf_ecualizada = cumsum(imhist(ecualizada) ./ numel(ecualizada));
subplot(3, 3, 6);
plot(cdf_ecualizada);
title('CDF de la Imagen Ecualizada');
xlabel('Intensidad de píxeles');
ylabel('CDF');

% Mejora de contraste
contrast_adjusted = imadjust(Caracterization, stretchlim(Caracterization), []);

% Imagen con contraste ajustado
subplot(3, 3, 7);
imshow(contrast_adjusted);
title('Imagen con Contraste Ajustado');

% Histograma de la imagen con contraste ajustado
subplot(3, 3, 8);
imhist(contrast_adjusted);
title('Histograma con Contraste Ajustado');

% CDF de la imagen con contraste ajustado
cdf_contrast_adjusted = cumsum(imhist(contrast_adjusted) ./ numel(contrast_adjusted));
subplot(3, 3, 9);
plot(cdf_contrast_adjusted);
title('CDF de la Imagen con Contraste Ajustado');
xlabel('Intensidad de píxeles');
ylabel('CDF');