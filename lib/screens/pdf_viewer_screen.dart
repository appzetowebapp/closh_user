import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:webview_master_app/utils/download_service.dart';

class PdfViewerScreen extends StatefulWidget {
  final String filePath;
  final String title;
  final String? originalUrl;

  const PdfViewerScreen({
    Key? key,
    required this.filePath,
    required this.title,
    this.originalUrl,
  }) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isSaving = false;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String _errorMessage = '';

  Future<void> _saveToDownloads() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final downloadService = DownloadService();
      
      // Request storage permission if needed for public downloads
      final hasPermission = await downloadService.requestStoragePermission(requirePublicAccess: true);
      
      if (hasPermission) {
        String filename = widget.title;
        if (!filename.toLowerCase().endsWith('.pdf')) {
          filename = '$filename.pdf';
        }
        
        await downloadService.addFileToMediaStore(
          widget.filePath, 
          filename, 
          'application/pdf',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Saved to Downloads folder'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'OPEN',
                textColor: Colors.white,
                onPressed: () {
                  downloadService.openFile(widget.filePath);
                },
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Storage permission denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _shareFile() {
    Share.shareXFiles([XFile(widget.filePath)], text: widget.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareFile,
            tooltip: 'Share',
          ),
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download),
            onPressed: _isSaving ? null : _saveToDownloads,
            tooltip: 'Save to Downloads',
          ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageFling: false,
            onRender: (_pages) {
              setState(() {
                _totalPages = _pages!;
                _isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                _errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              setState(() {
                _errorMessage = '$page: ${error.toString()}';
              });
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page!;
              });
            },
          ),
          if (_errorMessage.isEmpty && !_isReady)
            const Center(child: CircularProgressIndicator()),
          if (_errorMessage.isNotEmpty)
            Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))),
        ],
      ),
      floatingActionButton: _isReady && _totalPages > 0
          ? FloatingActionButton.extended(
              onPressed: () {},
              label: Text('${_currentPage + 1}/$_totalPages'),
              icon: const Icon(Icons.picture_as_pdf),
            )
          : null,
    );
  }
}
