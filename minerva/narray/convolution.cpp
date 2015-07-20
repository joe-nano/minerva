#include "narray/convolution.h"
#include "op/physical_op.h"

namespace minerva {

ImageBatch Convolution::ConvForward(ImageBatch src, Filter filter, NArray bias, ConvInfo info) {
  CHECK_EQ(src.GetNumFeatureMaps(), filter.GetNumInputs()) << "#input channels mismatch";
  CHECK_EQ(bias.Size().NumDims(), 1) << "bias dimension mismatch";
  CHECK_EQ(bias.Size()[0], filter.GetNumOutputs()) << "bias size mismatch";
  Scale new_size {
    (src.GetWidth() + 2 * info.pad_width - filter.GetWidth()) / info.stride_horizontal + 1,
    (src.GetHeight() + 2 * info.pad_height - filter.GetHeight()) / info.stride_vertical + 1,
    filter.GetNumOutputs(),
    src.GetNumImages()
  };
  ConvForwardOp* op = new ConvForwardOp();
  op->closure.pad_height = info.pad_height;
  op->closure.pad_width = info.pad_width;
  op->closure.stride_vertical = info.stride_vertical;
  op->closure.stride_horizontal = info.stride_horizontal;
  op->closure.algo = info.forward_algorithm;
  return NArray::ComputeOne({src, filter, bias}, new_size, op);
}

ImageBatch Convolution::ConvBackwardData(ImageBatch diff, ImageBatch bottom, Filter filter, ConvInfo info) {
  CHECK_EQ(diff.GetNumFeatureMaps(), filter.GetNumOutputs()) << "#output channels mismatch";
  ConvBackwardDataOp* op = new ConvBackwardDataOp();
  op->closure.pad_height = info.pad_height;
  op->closure.pad_width = info.pad_width;
  op->closure.stride_vertical = info.stride_vertical;
  op->closure.stride_horizontal = info.stride_horizontal;
  op->closure.algo = info.backward_data_algorithm;
  return NArray::ComputeOne({diff, filter}, bottom.Size(), op);
}

Filter Convolution::ConvBackwardFilter(ImageBatch diff, ImageBatch bottom, Filter filter, ConvInfo info) {
  CHECK_EQ(diff.GetNumImages(), bottom.GetNumImages()) << "#images mismatch";
  ConvBackwardFilterOp* op = new ConvBackwardFilterOp();
  op->closure.pad_height = info.pad_height;
  op->closure.pad_width = info.pad_width;
  op->closure.stride_vertical = info.stride_vertical;
  op->closure.stride_horizontal = info.stride_horizontal;
  op->closure.algo = info.backward_filter_algorithm;
  return NArray::ComputeOne({diff, bottom}, filter.Size(), op);
}

NArray Convolution::ConvBackwardBias(ImageBatch diff) {
  Scale new_size {
    diff.GetNumFeatureMaps()
  };
  ConvBackwardBiasOp* op = new ConvBackwardBiasOp();
  return NArray::ComputeOne({diff}, new_size, op);
}

std::vector<ConvFwdAlgoProfResult> Convolution::ConvForwardFindAlgorithm(
    Scale const& src_shape
  , Scale const& filter_shape
  , ConvInfo info) {
  auto&& src = ImageBatch{NArray::Zeros(src_shape)};
  auto&& filter = Filter{NArray::Zeros(filter_shape)};
  CHECK_EQ(src.GetNumFeatureMaps(), filter.GetNumInputs()) << "#input channels mismatch";
  Scale new_size {
    (src.GetWidth() + 2 * info.pad_width - filter.GetWidth()) / info.stride_horizontal + 1,
    (src.GetHeight() + 2 * info.pad_height - filter.GetHeight()) / info.stride_vertical + 1,
    filter.GetNumOutputs(),
    src.GetNumImages()
  };
  auto op = new ConvForwardFindAlgorithmOp{};
  auto res = std::make_shared<std::vector<ConvFwdAlgoProfResult>>();
  op->closure.results = res;
  op->closure.pad_height = info.pad_height;
  op->closure.pad_width = info.pad_width;
  op->closure.stride_vertical = info.stride_vertical;
  op->closure.stride_horizontal = info.stride_horizontal;
  auto ret = NArray::ComputeOne({src, filter}, new_size, op);
  ret.Wait();
  return *res;
}

std::vector<ConvBwdFilterAlgoProfResult> Convolution::ConvBackwardFilterFindAlgorithm(
    Scale const& top_shape
  , Scale const& bottom_shape
  , Scale const& filter_shape
  , ConvInfo info) {
  auto&& top = ImageBatch{NArray::Zeros(top_shape)};
  auto&& bottom = ImageBatch{NArray::Zeros(bottom_shape)};
  CHECK_EQ(top.GetNumImages(), bottom.GetNumImages()) << "#images mismatch";
  auto op = new ConvBackwardFilterFindAlgorithmOp{};
  auto res = std::make_shared<std::vector<ConvBwdFilterAlgoProfResult>>();
  op->closure.results = res;
  op->closure.pad_height = info.pad_height;
  op->closure.pad_width = info.pad_width;
  op->closure.stride_vertical = info.stride_vertical;
  op->closure.stride_horizontal = info.stride_horizontal;
  auto ret = NArray::ComputeOne({top, bottom}, filter_shape, op);
  ret.Wait();
  return *res;
}

std::vector<ConvBwdDataAlgoProfResult> Convolution::ConvBackwardDataFindAlgorithm(
    Scale const& top_shape
  , Scale const& bottom_shape
  , Scale const& filter_shape
  , ConvInfo info) {
  auto&& top = ImageBatch{NArray::Zeros(top_shape)};
  auto&& filter = Filter{NArray::Zeros(filter_shape)};
  CHECK_EQ(top.GetNumFeatureMaps(), filter.GetNumOutputs()) << "#output channels mismatch";
  auto op = new ConvBackwardDataFindAlgorithmOp{};
  auto res = std::make_shared<std::vector<ConvBwdDataAlgoProfResult>>();
  op->closure.results = res;
  op->closure.pad_height = info.pad_height;
  op->closure.pad_width = info.pad_width;
  op->closure.stride_vertical = info.stride_vertical;
  op->closure.stride_horizontal = info.stride_horizontal;
  auto ret = NArray::ComputeOne({top, filter}, bottom_shape, op);
  ret.Wait();
  return *res;
}

ImageBatch Convolution::SoftmaxForward(ImageBatch src, SoftmaxAlgorithm algorithm) {
  SoftmaxForwardOp* op = new SoftmaxForwardOp();
  op->closure.algorithm = algorithm;
  return NArray::ComputeOne({src}, src.Size(), op);
}

ImageBatch Convolution::SoftmaxBackward(ImageBatch diff, ImageBatch top, SoftmaxAlgorithm algorithm) {
  CHECK_EQ(diff.Size(), top.Size()) << "inputs sizes mismatch";
  SoftmaxBackwardOp* op = new SoftmaxBackwardOp();
  op->closure.algorithm = algorithm;
  return NArray::ComputeOne({diff, top}, diff.Size(), op);
}

ImageBatch Convolution::ActivationForward(ImageBatch src, ActivationAlgorithm algorithm) {
  ActivationForwardOp* op = new ActivationForwardOp();
  op->closure.algorithm = algorithm;
  return NArray::ComputeOne({src}, src.Size(), op);
}

ImageBatch Convolution::ActivationBackward(ImageBatch diff, ImageBatch top, ImageBatch bottom, ActivationAlgorithm algorithm) {
  CHECK_EQ(diff.Size(), top.Size()) << "inputs sizes mismatch";
  CHECK_EQ(diff.Size(), bottom.Size()) << "inputs sizes mismatch";
  ActivationBackwardOp* op = new ActivationBackwardOp();
  op->closure.algorithm = algorithm;
  return NArray::ComputeOne({diff, top, bottom}, diff.Size(), op);
}

ImageBatch Convolution::PoolingForward(ImageBatch src, PoolingInfo info) {
  int pooled_height = (src.GetHeight() + 2 * info.pad_height - info.height + info.stride_vertical - 1) / info.stride_vertical + 1;
  int pooled_width = (src.GetWidth() + 2 * info.pad_width - info.width + info.stride_horizontal - 1) / info.stride_horizontal + 1;
  if (0 <= (pooled_height - 1) * info.stride_vertical - src.GetHeight() - info.pad_height) {
    --pooled_height;
  }
  if (0 <= (pooled_width - 1) * info.stride_horizontal - src.GetWidth() - info.pad_width) {
    --pooled_width;
  }
  Scale new_size {
    pooled_height,
    pooled_width,
    src.GetNumFeatureMaps(),
    src.GetNumImages()
  };
  PoolingForwardOp* op = new PoolingForwardOp();
  op->closure = {
    info.algorithm,
    info.height,
    info.width,
    info.stride_vertical,
    info.stride_horizontal,
	info.pad_height,
	info.pad_width
  };
  return NArray::ComputeOne({src}, new_size, op);
}

ImageBatch Convolution::PoolingBackward(ImageBatch diff, ImageBatch top, ImageBatch bottom, PoolingInfo info) {
  CHECK_EQ(diff.Size(), top.Size()) << "inputs sizes mismatch";
  CHECK_EQ(diff.GetNumImages(), bottom.GetNumImages()) << "#images mismatch";
  CHECK_EQ(diff.GetNumFeatureMaps(), bottom.GetNumFeatureMaps()) << "#channels mismatch";

  int pooled_height = (bottom.GetHeight() + 2 * info.pad_height - info.height + info.stride_vertical - 1) / info.stride_vertical + 1;
  int pooled_width = (bottom.GetWidth() + 2 * info.pad_width - info.width + info.stride_horizontal - 1) / info.stride_horizontal + 1;
  if (0 <= (pooled_height - 1) * info.stride_vertical - bottom.GetHeight() - info.pad_height) {
    --pooled_height;
  }
  if (0 <= (pooled_width - 1) * info.stride_horizontal - bottom.GetWidth() - info.pad_width) {
    --pooled_width;
  }

  CHECK_EQ(top.GetHeight(), pooled_height) << "height mismatch";
  CHECK_EQ(top.GetWidth(), pooled_width) << "width mismatch";

  PoolingBackwardOp* op = new PoolingBackwardOp();
  op->closure = {
    info.algorithm,
    info.height,
    info.width,
    info.stride_vertical,
    info.stride_horizontal,
	info.pad_height,
	info.pad_width
  };
  return NArray::ComputeOne({diff, top, bottom}, bottom.Size(), op);
}


ImageBatch Convolution::LrnForward(ImageBatch src, int local_size, float alpha, float beta, float k) {
  auto op = new LrnForwardOp();
  op->closure = {local_size, alpha, beta, k};
  return NArray::ComputeOne({src}, src.Size(), op);
}

ImageBatch Convolution::LrnBackward(ImageBatch top, ImageBatch top_diff, ImageBatch bottom, int local_size, float alpha, float beta, float k) {
  CHECK_EQ(top.Size(), top_diff.Size()) << "inputs sizes mismatch";
  CHECK_EQ(top.Size(), bottom.Size()) << "inputs sizes mismatch";
  auto op = new LrnBackwardOp();
  op->closure = {local_size, alpha, beta, k};
  return NArray::ComputeOne({top, top_diff, bottom}, top.Size(), op);
}

}  // namespace minerva

