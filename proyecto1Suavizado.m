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
ImagenASuavizar = im2double(imread(fullfile(pathname, filename)));

% Si la imagen es a color, se cambia a ByN

if size(ImagenASuavizar, 3) == 3
    ImagenASuavizar = rgb2gray(ImagenASuavizar);
end

% Crear una figura para mostrar resultados
hFig = figure('Position', [100, 100, 800, 600]);

% Barra para controlar el valor de sigma
uicontrol('Style', 'text', 'Position', [50 40 200 20], 'String', 'Sigma');
SigmaSlider = uicontrol('Style', 'slider', 'Min', 0.1, 'Max', 10, 'Value', 1, 'Position', [50 20 400 20], 'SliderStep', [1/100, 1/100]);
SigmaValueText = uicontrol('Style', 'text', 'Position', [460 20 50 20], 'String', '1');

% Mostrar imagen original
subplot(2, 3, 1);
hImgOriginal = imshow(ImagenASuavizar); 
title('Imagen Original');

% Histograma de la imagen original
subplot(2, 3, 2);
imhist(ImagenASuavizar);
title('Histograma Original');

% CDF de la imagen original
subplot(2, 3, 3);
hCdfOriginal = plot(cumsum(imhist(ImagenASuavizar) / numel(ImagenASuavizar)));
title('CDF de la Imagen Original');
xlabel('Intensidad de píxeles');
ylabel('CDF');

% Función para actualizar la imagen cuando el slider cambia
function updateImage(src, event, SigmaValueText, ImagenASuavizar)
    % Obtener el valor de sigma del slider
    sigma = src.Value;
    set(SigmaValueText, 'String', num2str(sigma));
    
    % Aplicar el filtro gaussiano con el sigma actual
    ImagenSuavizada = imgaussfilt(ImagenASuavizar, sigma);
    
    % Mostrar la imagen suavizada
    subplot(2, 3, 4);
    imshow(ImagenSuavizada);
    title(['Imagen Suavizada (Sigma = ' num2str(sigma) ')']);
    
    % Histograma de la imagen suavizada
    subplot(2, 3, 5);
    imhist(ImagenSuavizada);
    title('Histograma Imagen Suavizada');
    
    % CDF de la imagen suavizada
    subplot(2, 3, 6);
    plot(cumsum(imhist(ImagenSuavizada) / numel(ImagenSuavizada)));
    title('CDF de la Imagen Suavizada');
    xlabel('Intensidad de píxeles');
    ylabel('CDF');
end

% Establecer la función de callback para el slider
set(SigmaSlider, 'Callback', @(src, event) updateImage(src, event, SigmaValueText, ImagenASuavizar));

% Ejecutar la función una vez para mostrar la imagen inicial
updateImage(SigmaSlider, [], SigmaValueText, ImagenASuavizar);