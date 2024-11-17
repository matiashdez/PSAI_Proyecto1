clear all
close all
clc

% Selección de archivo
[filename, pathname] = uigetfile({'*.jpg;*.png;*.tif', 'Imágenes (*.jpg, *.png, *.tif)'}, 'Selecciona una imagen');
if isequal(filename, 0)
   disp('No se seleccionó ninguna imagen');
   return;
end

% Leer la imagen y convertirla a double
ImagenARealzar = im2double(imread(fullfile(pathname, filename)));

% Si la imagen es a color, se cambia a ByN
if size(ImagenARealzar, 3) == 3
    ImagenARealzar = rgb2gray(ImagenARealzar);
end

% Crear una figura para mostrar resultados
hFig = figure('Position', [100, 100, 800, 600]);

% Mostrar imagen original
subplot(3, 3, 1);
imshow(ImagenARealzar); 
title('Imagen Original');

% Histograma de la imagen original
subplot(3, 3, 2);
imhist(ImagenARealzar);
title('Histograma Original');

% CDF de la imagen original
subplot(3, 3, 3);
plot(cumsum(imhist(ImagenARealzar) / numel(ImagenARealzar)));
title('CDF de la Imagen Original');
xlabel('Intensidad de píxeles');
ylabel('CDF');

% Crear filtros Sobel (gradiente horizontal y vertical)
filtro_sobel_x = fspecial('sobel');
filtro_sobel_y = filtro_sobel_x';

% Aplicar los filtros Sobel
gradiente_x = imfilter(ImagenARealzar, filtro_sobel_x, 'replicate');
gradiente_y = imfilter(ImagenARealzar, filtro_sobel_y, 'replicate');

% Calcular la magnitud del gradiente (bordes)
imagen_bordes = sqrt(gradiente_x.^2 + gradiente_y.^2);

% Sumar la imagen realzada a la original para intensificar los bordes
ImagenRealzada = ImagenARealzar + imagen_bordes;

% Asegurar que los valores están dentro del rango [0, 1]
ImagenRealzada = mat2gray(ImagenRealzada);

% Mostrar la imagen realzada
subplot(3, 3, 4);
imshow(ImagenRealzada);
title('Imagen Realzada');

% Histograma de la imagen realzada
subplot(3, 3, 5);
imhist(ImagenRealzada);
title('Histograma Imagen Realzada');

% CDF de la imagen realzada
subplot(3, 3, 6);
plot(cumsum(imhist(ImagenRealzada) / numel(ImagenRealzada)));
title('CDF de la Imagen Realzada');
xlabel('Intensidad de píxeles');
ylabel('CDF');

% Mostrar los bordes
subplot(3, 3, 7);
imshow(mat2gray(imagen_bordes));
title('Bordes Detectados (Sobel)');

% Histograma de los bordes
subplot(3, 3, 8);
imhist(mat2gray(imagen_bordes));
title('Histograma Bordes');

% CDF de los bordes
subplot(3, 3, 9);
plot(cumsum(imhist(mat2gray(imagen_bordes)) / numel(imagen_bordes)));
title('CDF Bordes');
xlabel('Intensidad de píxeles');
ylabel('CDF');