import 'package:flutter/material.dart';

class MixinFutureBuilder extends StatefulWidget {
  final Future future;
  final AsyncWidgetBuilder builder;

  const MixinFutureBuilder(
      {super.key, required this.future, required this.builder});

  @override
  State<MixinFutureBuilder> createState() => _MixinFutureBuilderState();
}

class _MixinFutureBuilderState extends State<MixinFutureBuilder>
    with AutomaticKeepAliveClientMixin<MixinFutureBuilder> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(future: widget.future, builder: widget.builder);
  }
}
