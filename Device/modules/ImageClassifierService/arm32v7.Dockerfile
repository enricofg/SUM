#FROM arm32v7/python:3.7-slim-stretch
FROM balenalib/raspberrypi3-python:3.7.12-latest-build

RUN [ "cross-build-start" ]
WORKDIR /usr/src/app


RUN pwd & ls
RUN apt update && apt install -y libjpeg62-turbo libopenjp2-7 libtiff5 libatlas-base-dev libgl1-mesa-glx
RUN pip3 install absl-py six protobuf wrapt gast astor termcolor keras_applications keras_preprocessing --no-deps
RUN pip install numpy==1.16 tensorflow==1.13.1 --extra-index-url 'https://www.piwheels.org/simple' --no-deps
RUN pip install flask pillow --index-url 'https://www.piwheels.org/simple'

WORKDIR /app
# RUN pwd 
# RUN ls
COPY app .
# Expose the port
# RUN ls

EXPOSE 80

# Set the working directory

RUN pwd & ls
RUN [ "cross-build-end" ]
RUN ls
CMD [ "python", "./app.py" ]