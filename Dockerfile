# 1. Start with a lightweight Linux OS that already has Python installed
FROM python:3.9-slim

# 2. Install the C-Compiler tools (GCC, Make, Flex, Bison)
RUN apt-get update && apt-get install -y gcc make flex bison

# 3. Install the music library
RUN pip install music21

# 4. Create a folder for the compiler source code
WORKDIR /compiler
COPY . /compiler

# 5. Compile the Maestro C code and install it globally inside the container
RUN make clean && make
RUN cp maestro /usr/local/bin/maestro

# 6. Create a separate working directory for the user's music files
WORKDIR /work

# 7. Tell Docker that whenever this container runs, it acts as the 'maestro' command
ENTRYPOINT ["maestro"]
