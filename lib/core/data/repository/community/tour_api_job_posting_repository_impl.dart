// The public constructor parameter intentionally initializes a private dependency.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/domain/repository/community/tour_api_job_posting_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/di/di.dart';
import 'package:meomum/feature/community/domain/model/tour_api_job_posting.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TourApiJobPostingRepositoryImpl implements TourApiJobPostingRepository {
  final SupabaseClient _client;

  const TourApiJobPostingRepositoryImpl({required SupabaseClient client})
    : _client = client;

  @override
  Future<Result<List<TourApiJobPosting>>> getJobPostings({
    required String upperRegion,
    required String lowerRegion,
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('tour_api_job_postings')
          .select()
          .eq('upper_region', upperRegion)
          .eq('lower_region', lowerRegion)
          .order('is_always_recruiting', ascending: false)
          .order('recruitment_deadline', ascending: true, nullsFirst: false)
          .order('registered_at', ascending: false)
          .limit(limit);

      final postings = (response as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(_toModel)
          .toList();
      postings.sort((TourApiJobPosting left, TourApiJobPosting right) {
        if (left.isClosed != right.isClosed) {
          return left.isClosed ? 1 : -1;
        }
        return (right.registeredAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(
              left.registeredAt ?? DateTime.fromMillisecondsSinceEpoch(0),
            );
      });
      return Result.success(postings);
    } on PostgrestException catch (error) {
      return Result.failure('관광인 채용정보를 불러오지 못했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('관광인 채용정보를 불러오지 못했습니다: $error');
    }
  }

  @override
  Future<Result<TourApiJobPosting>> getJobPostingById({
    required String empmnInfoNo,
  }) async {
    try {
      final response = await _client
          .from('tour_api_job_postings')
          .select()
          .eq('empmn_info_no', empmnInfoNo)
          .single();
      return Result.success(_toModel(response));
    } on PostgrestException catch (error) {
      return Result.failure('관광인 채용정보를 불러오지 못했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('관광인 채용정보를 불러오지 못했습니다: $error');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getDetail({
    required String empmnInfoNo,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'tour-job-detail',
        body: <String, String>{'empmnInfoNo': empmnInfoNo},
      );
      final data = response.data;
      if (data is! Map) {
        return const Result.failure('상세 채용정보 형식이 올바르지 않습니다.');
      }
      final detail = data['detail'];
      if (detail is! Map) {
        return const Result.failure('상세 채용정보가 없습니다.');
      }
      return Result.success(Map<String, dynamic>.from(detail));
    } on FunctionException catch (error) {
      return Result.failure('상세 채용정보를 불러오지 못했습니다: $error');
    } catch (error) {
      return Result.failure('상세 채용정보를 불러오지 못했습니다: $error');
    }
  }

  TourApiJobPosting _toModel(Map<String, dynamic> row) {
    return TourApiJobPosting(
      empmnInfoNo: row['empmn_info_no'] as String,
      upperRegion: row['upper_region'] as String,
      lowerRegion: row['lower_region'] as String,
      companyName: row['company_name'] as String?,
      title: row['title'] as String,
      workplace: row['workplace'] as String?,
      salary: row['salary'] as String?,
      wageType: row['wage_type'] as String?,
      employmentType: row['employment_type'] as String?,
      careerCondition: row['career_condition'] as String?,
      recruitmentCount: row['recruitment_count'] as String?,
      workingTime: row['working_time'] as String?,
      recruitmentDeadline: _parseDate(row['recruitment_deadline']),
      isAlwaysRecruiting: row['is_always_recruiting'] as bool? ?? false,
      registeredAt: _parseDate(row['registered_at']),
      modifiedAt: _parseDate(row['modified_at']),
      originalUrl: row['original_url'] as String?,
      detailPayload: _mapValue(row['detail_payload']),
    );
  }

  DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  Map<String, dynamic>? _mapValue(Object? value) {
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }
}

final tourApiJobPostingRepositoryProvider =
    Provider<TourApiJobPostingRepository>((Ref ref) {
      return TourApiJobPostingRepositoryImpl(
        client: ref.watch(supabaseClientProvider),
      );
    });
