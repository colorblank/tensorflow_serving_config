TF_VERSION=r2.18
BASE_DIR=$(pwd)

# Clean up previous runs
rm -rf proto_source tmp src .venv dist build *.egg-info

# Create directories
mkdir -p proto_source
mkdir -p tmp
mkdir -p src
mkdir -p src/tensorflow_serving
mkdir -p src/tensorflow_serving/config

# Create __init__.py for tensorflow_serving package
echo '' > src/tensorflow_serving/__init__.py

# Set up Python virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Clone TensorFlow Serving repository
git clone https://github.com/tensorflow/serving.git proto_source/serving

# Copy relevant proto files to tmp
cp -r proto_source/serving/tensorflow_serving $BASE_DIR/tmp



python -m grpc_tools.protoc \
       --proto_path=./tmp \
       --python_out=./src \
       ./tmp/tensorflow_serving/config/*.proto 

echo '__version__ = "0.0.1"' > src/tensorflow_serving/config/__init__.py
# Clean up temporary directories
rm -rf tmp proto_source

# Install the package in editable mode
pip install -e .

# Run the comprehensive test script
python test.py
# Add src to PYTHONPATH for local development/testing
export PYTHONPATH=$BASE_DIR/src:$PYTHONPATH

# Build the wheel file
python setup.py sdist bdist_wheel

# todo: 1. test load file and generate file, 2. upload to pypi
# use github actions to automate the process
