FROM public.ecr.aws/lambda/python:3.8
ENV PYTHONIOENCODING=utf-8

WORKDIR shotvet

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    python3-pip \
    libgl1-mesa-glx \
    python-pkg-resources \
    maven
    # Remove unnecessary cache which reduces image size at the end

COPY requirements.txt 
COPY lambda_app.py ./

RUN pip3 install --upgrade pip
#The final pip command returns with a non zero return. Which crashes hence the addition of exit 0
RUN cat requirements.txt | xargs -n 1 pip3 install; exit 0 

RUN mvn dependency:copy-dependencies -DoutputDirectory=./jars -f $(python3 -c 'import importlib; import pathlib; print(pathlib.Path(importlib.util.find_spec("sutime").origin).parent / "pom.xml")')

#EXPOSE 5000

# ENTRYPOINT ["python3", "app.py"]

CMD ["lambda_app.lambda_handler"]

# CMD []
