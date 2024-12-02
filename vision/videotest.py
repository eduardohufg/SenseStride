import cv2
import numpy as np
from gpiozero import LED

# Abrir el video
cap = cv2.VideoCapture('corro.mp4')
izq = LED(23)
der = LED(24)

# Obtener las dimensiones del video y la tasa de fotogramas (frames por segundo)
frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
fps = int(cap.get(cv2.CAP_PROP_FPS))

# Definir el codec y el objeto para guardar el video resultante
out = cv2.VideoWriter('resultado_video.mp4', cv2.VideoWriter_fourcc(*'mp4v'), fps, (frame_width, frame_height))

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break  # Salir si no hay más cuadros
    
    # Flip the frame vertically
    frame =cv2.flip(frame,0)
    
    # Convertir el cuadro a escala de grises
    gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Aplicar el filtro bilateral
    bifilter = cv2.bilateralFilter(src=gray_frame, d=7, sigmaColor=75, sigmaSpace=75)

    # Detección de bordes con Canny
    canny = cv2.Canny(bifilter, 30, 100, apertureSize = 3, L2gradient = False)

    # Crear una máscara y aplicar el filtro de bordes
    mask = np.zeros_like(canny)
    rows, cols = canny.shape[:2]
    bottom_left = [cols * 0, rows * 1]
    bottom_right = [cols * 1, rows * 1]
    top_left = [cols * 0.01, rows * 0.4]
    top_right = [cols * 0.99, rows * 0.4]
    vertices = np.array([[bottom_left, top_left, top_right, bottom_right]], dtype=np.int32)
    cv2.fillPoly(mask, vertices, 255)
    cannyb = cv2.bitwise_and(canny, mask)

    # Detectar líneas con Hough
    lines = cv2.HoughLinesP(
        image=cannyb,
        rho=1,
        theta=np.pi/180,
        threshold=100,
        minLineLength=25,
        maxLineGap=75
    )
    
    # Calcular el centro del cuadro
    center_x, center_y = frame_width // 2, frame_height // 2

    # Dibujar las líneas detectadas en el cuadro
    if lines is not None:
        for line in lines:
            x1, y1, x2, y2 = line[0]
            cv2.line(frame, (x1, y1), (x2, y2), (255, 0, 0), 5)
            #print(x2)
            
            error = center_x - x2
            print(error)
            if(error > 130) or (error < -200):
                print("centro centreo centro")
                der.off()
                izq.off()
            else:
                if(error < 0):
                    print("IZQUIERDAAAA")
                    der.on()
                elif(error > 0):
                    print("DERECHAAAAA")
                    izq.on()
   # Dibujar un punto rojo en el centroCLEAR
    cv2.circle(frame, (center_x, center_y), radius=5, color=(255, 0, 255), thickness=-1)

    # Guardar el cuadro procesado en el video de salida
    out.write(frame)

    # Mostrar el cuadro procesado en tiempo real (opcional)
    cv2.imshow('Video Procesado', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Liberar recursos
cap.release()
out.release()
cv2.destroyAllWindows()