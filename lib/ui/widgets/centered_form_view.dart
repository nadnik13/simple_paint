import 'package:flutter/widgets.dart';

class CenteredFormView extends StatefulWidget {
  final Widget body;
  final List<Widget> actions;

  const CenteredFormView({
    required this.body,
    required this.actions,
    super.key,
  });

  @override
  State<CenteredFormView> createState() => _CentredFormViewState();
}

class _CentredFormViewState extends State<CenteredFormView> {
  final _buttonColumnKey = GlobalKey();
  double _inputBottomPadding = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isKeyboardOpened = MediaQuery.of(context).viewPadding.bottom == 0;
    if (isKeyboardOpened) {
      final ro = _buttonColumnKey.currentContext?.findRenderObject();
      if (ro is RenderBox && ro.hasSize) {
        _inputBottomPadding = ro.size.height + 8;
      }
    } else {
      _inputBottomPadding = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: _inputBottomPadding + 8),
                child: widget.body,
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            key: _buttonColumnKey,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: widget.actions,
          ),
        ),
      ],
    );
  }
}
