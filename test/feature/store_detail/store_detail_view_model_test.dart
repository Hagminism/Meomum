import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/feature/store_detail/presentation/screen/store_detail_view_model.dart';

void main() {
  test('페이지 로딩이 완료되면 WebView 오류 상태를 해제한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      storeDetailViewModelProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);

    final viewModel = container.read(storeDetailViewModelProvider.notifier);
    viewModel.onMainFrameError();

    expect(viewModel.state.hasWebViewError, isTrue);

    viewModel.onPageFinished();

    expect(viewModel.state.hasWebViewError, isFalse);
    expect(viewModel.state.isWebViewLoading, isFalse);
    expect(viewModel.state.webViewProgress, 100);
  });
}
