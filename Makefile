# Location of the CUDA Toolkit
CUDA_PATH ?= "/usr/local/cuda-8.0"

SOURCES := \
	src/main.cu

INCPATH := \
	-I. \
	-I/usr/local/cuda/include

OBJECTS0 = $(patsubst %.cpp,$(GENERATED_DIR)/%.o,$(SOURCES))
OBJECTS1 = $(patsubst %.c,$(GENERATED_DIR)/%.o,$(OBJECTS0))
OBJECTS = $(patsubst %.cu,$(GENERATED_DIR)/%.o,$(OBJECTS1))

GENERATED_DIR := generated_files

DEPDIR := .d
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td
POSTCOMPILE = @mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d

LINK := g++

LFLAGS := -Wl,-Bsymbolic -Wl,-O1 -lbz2 
#-L /usr/lib/x86_64-linux-gnu -lcudart_static  -lnvrtc -lcuda \
#	-L$(CUDA_PATH)/lib64 -L$(CUDA_PATH)/lib64/stubs

CXX := g++
CXXFLAGS = -c -pipe -Wno-multichar -g -fPIC -std=gnu++11 -Wall -W 

HOST_COMPILER ?= $(CXX)
NVCC          := nvcc -ccbin $(HOST_COMPILER)

TARGET := bin/cuda

# -L/usr/local/lib64 -L/usr/lib/"nvidia-367" -lGL -lGLU -lX11 -lglut -lcuda -lcudart -lnvrtc-builtins
	# $(LINK) -o $(TARGET) $(LFLAGS) $(OBJECTS) 
	#$(NVCC) -m64 -gencode arch=compute_20,code=sm_20 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52   -o $(TARGET) $(OBJECTS)  -L/usr/local/lib64 -L/usr/lib/"nvidia-367" -lGL -lGLU -lX11 -lglut -lnvrtc -lcuda -lcudart_static

$(TARGET): $(OBJECTS)
	mkdir -p $(@D)
	$(LINK) -m64 -o $(TARGET)  $(OBJECTS) -L/usr/local/cuda/lib64  -lcudart  -lcuda -lnvrtc 

$(GENERATED_DIR)/%.o : %.cpp 
	@mkdir -p $(@D)
	# $(NVCC)  -c $(INCPATH) $(NVCCFLAGS) -std=c++11 $(DEFINES) -o $@  $<
	"/usr/local/cuda-8.0"/bin/nvcc -c -ccbin g++ -std=c++11 $(INCPATH)  -m64    -gencode arch=compute_20,code=sm_20 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 -gencode arch=compute_60,code=sm_60 -gencode arch=compute_60,code=compute_60  -o $@  $<

$(GENERATED_DIR)/%.o : %.cu 
	@mkdir -p $(@D)
	# $(NVCC)  -c $(INCPATH) $(NVCCFLAGS) -std=c++11 $(DEFINES) -o $@  $<
	"/usr/local/cuda-8.0"/bin/nvcc -c -ccbin g++ -std=c++11 $(INCPATH)  -m64    -gencode arch=compute_20,code=sm_20 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 -gencode arch=compute_60,code=sm_60 -gencode arch=compute_60,code=compute_60  -o $@  $<


clean:
	@rm -f $(TARGET)
	@rm -rf $(GENERATED_DIR)
	@rm -rf $(DEPDIR)

# ---------------------------------------------------------------------------------------
# This has been very carefully crafted to make the dependencies work.
# Mess with it at your peril

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

INCDEPS := $(patsubst %.cpp,$(DEPDIR)/%.d,$(SOURCES))
INCDEPS := $(patsubst %.c,$(DEPDIR)/%.d,$(INCDEPS))
INCDEPS := $(patsubst %.cu,$(DEPDIR)/%.d,$(INCDEPS))

include $(wildcard $(INCDEPS))

