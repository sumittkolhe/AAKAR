import onnx
model = onnx.load("assets/models/affectnet_model.onnx")
print("Input info:")
for input in model.graph.input:
    print(input.name, input.type.tensor_type.shape.dim)

print("\nOutput info:")
for output in model.graph.output:
    print(output.name, output.type.tensor_type.shape.dim)
