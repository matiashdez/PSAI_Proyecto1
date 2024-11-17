clear all
close all
clc

% Selección de archivo
[filename, pathname] = uigetfile({'*.jpg;*.png;*.tif', 'Imágenes (*.jpg, *.png, *.tif)'}, 'Selecciona una imagen');
if isequal(filename, 0)
    disp('No se seleccionó ninguna imagen');
    return;
end

% Leer la imagen seleccionada y convertirla a escala de grises y tipo double
PatternDetection = imread(fullfile(pathname, filename));
if size(PatternDetection, 3) > 1
    PatternDetection = rgb2gray(PatternDetection); % Convertir a escala de grises si es necesario
end
PatternDetection = double(PatternDetection) / 255; % Normalizar al rango [0, 1]

% Mostrar la imagen original para selección del patrón
figure, imshow(PatternDetection, [0 1]);
title('Haz clic en las esquinas superior izquierda e inferior derecha del patrón');
disp('Selecciona dos puntos: superior izquierda e inferior derecha del patrón.');

% Selección interactiva de las esquinas del patrón
[x, y] = ginput(2);

% Validar que se seleccionaron exactamente dos puntos
if numel(x) < 2 || numel(y) < 2
    error('No seleccionaste dos puntos. Por favor, vuelve a intentarlo.');
end

% Convertir las coordenadas a enteros
x = round(x);
y = round(y);

% Validar coordenadas para asegurar que están dentro de los límites
x = max(1, min(size(PatternDetection, 2), x));
y = max(1, min(size(PatternDetection, 1), y));

% Obtener las esquinas del patrón
x1 = min(x); x2 = max(x);
y1 = min(y); y2 = max(y);

% Validar que el patrón tenga dimensiones adecuadas
if x2 - x1 < 1 || y2 - y1 < 1
    error('El área seleccionada es inválida. Por favor, selecciona un patrón más grande.');
end

% Extraer el patrón seleccionado y convertir a tipo double
Pattern = PatternDetection(y1:y2, x1:x2);

% Mostrar el patrón seleccionado
figure, imshow(Pattern, [0 1]);
title('Patrón Seleccionado');
disp('Patrón extraído correctamente.');
drawnow; % Forzar actualización de la figura

% Crear funciones para cálculos específicos
ImageCovariance = @(A, B) conv2(A - mean(A(:)), B(end:-1:1, end:-1:1) - mean(B(:)), 'same');
ImageAutocovariance = @(A, B) conv2(A.^2, ones(size(B)), 'same') - ...
                            (conv2(A, ones(size(B)), 'same').^2) / numel(B);

% Validar dimensiones del patrón respecto a la imagen
if size(Pattern, 1) > size(PatternDetection, 1) || size(Pattern, 2) > size(PatternDetection, 2)
    error('El patrón seleccionado es más grande que la imagen.');
end

% Ajustar dimensiones del patrón para asegurar compatibilidad
padSize = [size(PatternDetection, 1) - size(Pattern, 1), size(PatternDetection, 2) - size(Pattern, 2)];
Pattern = padarray(Pattern, padSize, 0, 'post'); % Rellenar con ceros

% Umbral de correlación
CorrelationThreshold = 0.6;

% Calcular el coeficiente de correlación de Pearson
PearsonCorrelationCoefficient = ImageCovariance(PatternDetection, Pattern);
PearsonCorrelationCoefficientDem = sqrt(abs(ImageAutocovariance(PatternDetection, Pattern)) .* ...
                                        abs(ImageAutocovariance(Pattern, Pattern)));

% Normalizar coeficiente para evitar divisiones por cero
index = find(PearsonCorrelationCoefficientDem ~= 0);
PearsonCorrelationCoefficient(index) = PearsonCorrelationCoefficient(index) ./ ...
                                       PearsonCorrelationCoefficientDem(index);

% Aplicar el umbral de correlación
PearsonCorrelationCoefficient = PearsonCorrelationCoefficient .* ...
                                (PearsonCorrelationCoefficient > CorrelationThreshold);

% Mostrar resultados
figure, set(gcf, 'Name', 'Pattern Detection: Result', 'Position', get(0, 'Screensize'));
subplot(1, 2, 1), imshow(PearsonCorrelationCoefficient * 50 + PatternDetection, [0 1]);
axis off square, colormap gray;
title('Pearson Correlation Coefficient');

% Cambiar el mapa de colores para destacar áreas correlacionadas
map = colormap('gray');
map(256, :) = [1 1 0]; % Resaltar con amarillo
colormap(map);

subplot(1, 2, 2), mesh(PearsonCorrelationCoefficient);
axis off square, set(gca, 'YDir', 'reverse');
title('Pearson Correlation Coefficient');
