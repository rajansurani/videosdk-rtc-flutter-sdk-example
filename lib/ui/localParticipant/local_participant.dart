import 'package:example/ui/utils/dragger.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/meeting.dart';
import 'package:videosdk/participant.dart';
import 'package:videosdk/stream.dart';
import 'package:videosdk/rtc.dart';

class LocalParticipant extends StatefulWidget {
  final Participant localParticipant;
  final Meeting meeting;

  LocalParticipant({
    Key? key,
    required this.localParticipant,
    required this.meeting,
  }) : super(key: key);

  @override
  LocalParticipantState createState() => LocalParticipantState();
}

class LocalParticipantState extends State<LocalParticipant> {
  List<MediaDeviceInfo> webcams = [];
  List<MediaDeviceInfo> mics = [];
  String? selectedWebcamId;
  String? selectedMicId;

  double? boxTop;
  double? boxLeft;
  double? boxRight;
  double? boxBottom;

  Stream? shareStream;
  Stream? videoStream;
  Stream? audioStream;

  @override
  initState() {
    _initStreamListners();

    super.initState();

    boxTop = null;
    boxLeft = 20;
    boxRight = null;
    boxBottom = 100;

    selectedWebcamId = widget.meeting.selectedWebcamId;
    selectedMicId = widget.meeting.selectedMicId;

    final _webcams = widget.meeting.getWebcams();

    webcams = _webcams;
  }

  _initStreamListners() {
    widget.localParticipant.on(
      "stream-enabled",
      (Stream _stream) {
        if (_stream.kind == 'video') {
          setState(
            () {
              videoStream = _stream;
            },
          );
        } else if (_stream.kind == 'audio') {
          setState(
            () {
              audioStream = _stream;
            },
          );
        } else if (_stream.kind == 'share') {
          setState(
            () {
              shareStream = _stream;
            },
          );
        }
      },
    );

    widget.localParticipant.on(
      "stream-disabled",
      (Stream _stream) {
        if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
          setState(
            () {
              videoStream = null;
            },
          );
        } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
          setState(
            () {
              audioStream = null;
            },
          );
        } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
          setState(
            () {
              shareStream = null;
            },
          );
        }
      },
    );
  }

  Widget build(BuildContext context) {
    return videoStream != null && videoStream?.renderer != null
        ? Dragger(
            key: ValueKey('Dragger'),
            child: Container(
              key: ValueKey('RenderMe_Border'),
              width: 180,
              height: 180,
              // margin: const EdgeInsets.only(left: 5, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.teal,
                  width: 2.0,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child2: Container(
              key: ValueKey('RenderMe_View'),
              width: 180 - 4,
              height: 180 - 4,
              margin: const EdgeInsets.all(2),
              child: ClipOval(
                child: RTCVideoView(
                  videoStream?.renderer as RTCVideoRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          )
        : SizedBox.shrink();
  }
}
