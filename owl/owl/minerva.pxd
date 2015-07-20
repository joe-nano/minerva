from libc.stdint cimport *
from libcpp cimport bool
from libcpp.vector cimport vector

cdef extern from './minerva_utils.h' namespace 'libowl':
  uint64_t CreateCpuDevice() except +
  uint64_t CreateGpuDevice(int) except +
  int GetGpuDeviceCount() except +
  void WaitForAll() except +
  void SetDevice(uint64_t) except +
  Scale ToScale(vector[int]*) except +
  vector[int] OfScale(const Scale&) except +
  NArray FromNumpy(const float*, const Scale&) except +
  void ToNumpy(float*, const NArray&) except +

cdef extern from '../minerva/minerva.h' namespace 'minerva::MinervaSystem':
  void Initialize(int*, char***) except +
  int has_cuda_

cdef extern from '../minerva/minerva.h' namespace 'minerva::Elewise':
  NArray Mult(const NArray&, const NArray&) except +
  NArray Exp(const NArray&) except +
  NArray Ln(const NArray&) except +
  NArray SigmoidForward(const NArray&) except +
  NArray SigmoidBackward(const NArray&, const NArray&, const NArray&) except +
  NArray ReluForward(const NArray&) except +
  NArray ReluBackward(const NArray&, const NArray&, const NArray&) except +
  NArray TanhForward(const NArray&) except +
  NArray TanhBackward(const NArray&, const NArray&, const NArray&) except +

cdef extern from '../minerva/minerva.h' namespace 'minerva::Convolution':
  NArray ConvForward(NArray, NArray, NArray, ConvInfo) except +
  NArray ConvBackwardData(NArray, NArray, NArray, ConvInfo) except +
  NArray ConvBackwardFilter(NArray, NArray, NArray, ConvInfo) except +
  NArray ConvBackwardBias(NArray) except +
  vector[ConvFwdAlgoProfResult] ConvForwardFindAlgorithm(
      const Scale&, const Scale&, ConvInfo) except +
  vector[ConvBwdFilterAlgoProfResult] ConvBackwardFilterFindAlgorithm(
      const Scale&, const Scale&, const Scale&, ConvInfo) except +
  vector[ConvBwdDataAlgoProfResult] ConvBackwardDataFindAlgorithm(
      const Scale&, const Scale&, const Scale&, ConvInfo) except +
  NArray SoftmaxForward(NArray, SoftmaxAlgorithm) except +
  NArray SoftmaxBackward(NArray, NArray, SoftmaxAlgorithm) except +
  NArray ActivationForward(NArray, ActivationAlgorithm) except +
  NArray ActivationBackward(
      NArray, NArray, NArray, ActivationAlgorithm) except +
  NArray PoolingForward(NArray, PoolingInfo) except +
  NArray PoolingBackward(NArray, NArray, NArray, PoolingInfo) except +
  NArray LrnForward(NArray, int, float, float, float) except +
  NArray LrnBackward(
      NArray, NArray, NArray, int, float, float, float) except +

cdef extern from '../minerva/minerva.h' namespace 'minerva':
  NArray NArrayAddNArray 'operator+'(const NArray&, const NArray&) except +
  NArray NArraySubNArray 'operator-'(const NArray&, const NArray&) except +
  NArray NArrayMulNArray 'operator*'(const NArray&, const NArray&) except +
  NArray NArrayDivNArray 'operator/'(const NArray&, const NArray&) except +
  NArray NumAddNArray 'operator+'(float, const NArray&) except +
  NArray NumSubNArray 'operator-'(float, const NArray&) except +
  NArray NumMulNArray 'operator*'(float, const NArray&) except +
  NArray NumDivNArray 'operator/'(float, const NArray&) except +
  NArray NArrayAddNum 'operator+'(const NArray&, float) except +
  NArray NArraySubNum 'operator-'(const NArray&, float) except +
  NArray NArrayMulNum 'operator*'(const NArray&, float) except +
  NArray NArrayDivNum 'operator/'(const NArray&, float) except +
  NArray Concat(const vector[NArray]&, int) except +
  NArray Slice(const NArray&, int, int, int) except +

  cppclass Scale:
    pass

  cppclass NArray:
    NArray() except +
    NArray assign 'operator='(const NArray&) except +
    NArray AddAssignNArray 'operator+='(const NArray&) except +
    NArray SubAssignNArray 'operator-='(const NArray&) except +
    NArray MulAssignNArray 'operator*='(const NArray&) except +
    NArray DivAssignNArray 'operator/='(const NArray&) except +
    NArray AddAssignNum 'operator+='(float) except +
    NArray SubAssignNum 'operator-='(float) except +
    NArray MulAssignNum 'operator*='(float) except +
    NArray DivAssignNum 'operator/='(float) except +
    NArray Sum(int) except +
    NArray Sum(const Scale&) except +
    NArray Max(int) except +
    NArray Max(const Scale&) except +
    NArray MaxIndex(int) except +
    int CountZero() except +
    NArray Trans() except +
    NArray Reshape(const Scale&) except +
    void Wait() except +
    Scale Size() except +
    @staticmethod
    NArray Zeros(const Scale&) except +
    @staticmethod
    NArray Ones(const Scale&) except +
    @staticmethod
    NArray Randn(const Scale&, float, float) except +
    @staticmethod
    NArray RandBernoulli(const Scale&, float) except +

  ctypedef enum ConvForwardAlgorithm 'minerva::ConvInfo::ForwardAlgorithm':
    kConvForwardAlgorithmImplicitGemm\
      'minerva::ConvInfo::ForwardAlgorithm::kImplicitGemm'
    kConvForwardAlgorithmImplicitPrecompGemm\
      'minerva::ConvInfo::ForwardAlgorithm::kImplicitPrecompGemm'
    kConvForwardAlgorithmGemm 'minerva::ConvInfo::ForwardAlgorithm::kGemm'
    kConvForwardAlgorithmDirect 'minerva::ConvInfo::ForwardAlgorithm::kDirect'
    kConvForwardAlgorithmFft 'minerva::ConvInfo::ForwardAlgorithm::kFft'
    kConvForwardAlgorithmAuto 'minerva::ConvInfo::ForwardAlgorithm::kAuto'
  int OfConvForwardAlgorithm\
    'libowl::OfEvilEnumClass'(ConvForwardAlgorithm) except +
  ConvForwardAlgorithm ToConvForwardAlgorithm\
    'libowl::ToEvilEnumClass<minerva::ConvInfo::ForwardAlgorithm>'(int)\
    except +

  ctypedef enum ConvBackwardDataAlgorithm\
      'minerva::ConvInfo::BackwardDataAlgorithm':
    kConvBackwardDataAlgorithmAlgo0\
      'minerva::ConvInfo::BackwardDataAlgorithm::kAlgo0'
    kConvBackwardDataAlgorithmAlgo1\
      'minerva::ConvInfo::BackwardDataAlgorithm::kAlgo1'
    kConvBackwardDataAlgorithmFft\
      'minerva::ConvInfo::BackwardDataAlgorithm::kFft'
    kConvBackwardDataAlgorithmAuto\
      'minerva::ConvInfo::BackwardDataAlgorithm::kAuto'
  int OfConvBackwardDataAlgorithm\
    'libowl::OfEvilEnumClass'(ConvBackwardDataAlgorithm) except +
  ConvBackwardDataAlgorithm ToConvBackwardDataAlgorithm\
    'libowl::ToEvilEnumClass<minerva::ConvInfo::BackwardDataAlgorithm>'(int)\
    except +

  ctypedef enum ConvBackwardFilterAlgorithm\
      'minerva::ConvInfo::BackwardFilterAlgorithm':
    kConvBackwardFilterAlgorithmAlgo0\
      'minerva::ConvInfo::BackwardFilterAlgorithm::kAlgo0'
    kConvBackwardFilterAlgorithmAlgo1\
      'minerva::ConvInfo::BackwardFilterAlgorithm::kAlgo1'
    kConvBackwardFilterAlgorithmFft\
      'minerva::ConvInfo::BackwardFilterAlgorithm::kFft'
    kConvBackwardFilterAlgorithmAuto\
      'minerva::ConvInfo::BackwardFilterAlgorithm::kAuto'
  int OfConvBackwardFilterAlgorithm\
    'libowl::OfEvilEnumClass'(ConvBackwardFilterAlgorithm) except +
  ConvBackwardFilterAlgorithm ToConvBackwardFilterAlgorithm\
    'libowl::ToEvilEnumClass<minerva::ConvInfo::BackwardFilterAlgorithm>'(int)\
    except +

  ctypedef enum PoolingAlgorithm 'minerva::PoolingInfo::Algorithm':
    kPoolingAlgorithmMax 'minerva::PoolingInfo::Algorithm::kMax'
    kPoolingAlgorithmAverage 'minerva::PoolingInfo::Algorithm::kAverage'
  int OfPoolingAlgorithm 'libowl::OfEvilEnumClass'(PoolingAlgorithm) except +
  PoolingAlgorithm ToPoolingAlgorithm\
    'libowl::ToEvilEnumClass<minerva::PoolingInfo::Algorithm>'(int) except +

  ctypedef enum SoftmaxAlgorithm 'minerva::SoftmaxAlgorithm':
    kSoftmaxAlgorithmInstance 'minerva::SoftmaxAlgorithm::kInstance'
    kSoftmaxAlgorithmChannel 'minerva::SoftmaxAlgorithm::kChannel'
  int OfSoftmaxAlgorithm 'libowl::OfEvilEnumClass'(SoftmaxAlgorithm) except +
  SoftmaxAlgorithm ToSoftmaxAlgorithm\
    'libowl::ToEvilEnumClass<minerva::SoftmaxAlgorithm>'(int) except +

  ctypedef enum ActivationAlgorithm 'minerva::ActivationAlgorithm':
    kActivationAlgorithmSigmoid 'minerva::ActivationAlgorithm::kSigmoid'
    kActivationAlgorithmRelu 'minerva::ActivationAlgorithm::kRelu'
    kActivationAlgorithmTanh 'minerva::ActivationAlgorithm::kTanh'
  int OfActivationAlgorithm\
    'libowl::OfEvilEnumClass'(ActivationAlgorithm) except +
  ActivationAlgorithm ToActivationAlgorithm\
    'libowl::ToEvilEnumClass<minerva::ActivationAlgorithm>'(int) except +

  cppclass ConvInfo:
    ConvInfo(
      int
    , int
    , int
    , int
    , ConvForwardAlgorithm
    , ConvBackwardDataAlgorithm
    , ConvBackwardFilterAlgorithm)
    int pad_height
    int pad_width
    int stride_vertical
    int stride_horizontal
    ConvForwardAlgorithm forward_algorithm
    ConvBackwardDataAlgorithm backward_data_algorithm
    ConvBackwardFilterAlgorithm backward_filter_algorithm

  cppclass PoolingInfo:
    PoolingInfo(PoolingAlgorithm, int, int, int, int, int, int)
    PoolingAlgorithm algorithm
    int height
    int width
    int stride_vertical
    int stride_horizontal
    int pad_height
    int pad_width

  cppclass ConvFwdAlgoProfResult:
    ConvForwardAlgorithm algo
    float time
    size_t memory

  cppclass ConvBwdFilterAlgoProfResult:
    ConvBackwardFilterAlgorithm algo
    float time
    size_t memory

  cppclass ConvBwdDataAlgoProfResult:
    ConvBackwardDataAlgorithm algo
    float time
    size_t memory
