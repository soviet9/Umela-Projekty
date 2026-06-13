from ultralytics import YOLO
import cv2

model = YOLO("runs/detect/moj_model-2/weights/best.pt")

cap = cv2.VideoCapture(1)

while True:
    ret, frame = cap.read()

    results = model(frame)

    annotated = results[0].plot()

    cv2.imshow("YOLO Detection", annotated)

    if cv2.waitKey(1) & 0xFF == ord('x'):
        break

cap.release()
cv2.destroyAllWindows()
