import torch;
device_count = torch.cuda.device_count();
print(f'Available GPUs: {device_count}');
if device_count == 0:
    raise RuntimeError("No GPUs found. If this is not expected, there may be a configuration issue.")
for i in range(device_count):
    major, minor = torch.cuda.get_device_capability(i);
    print(f'GPU #{i} Device Capability: {major}.{minor}');