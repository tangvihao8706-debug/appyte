class HealthArticle {
  final String title;
  final String imageUrl;

  HealthArticle(this.title, this.imageUrl);
}

class HealthService {
  // giả lập API
  static Future<List<HealthArticle>> fetchArticles() async {
    await Future.delayed(const Duration(seconds: 1)); // giả load mạng

    return [
      HealthArticle(
        "Nguy hiểm từ đơn thuốc AI",
        "https://cdn.tuoitre.vn/471584752817336320/2023/3/21/ai-y-te-1679378029810.jpg",
      ),
      HealthArticle(
        "Gia tăng ngộ độc thực phẩm",
        "https://cdn.tuoitre.vn/food-poison.jpg",
      ),
      HealthArticle(
        "Não mô cầu dễ gây tử vong",
        "https://cdn.tuoitre.vn/meningococcal.jpg",
      ),
    ];
  }
}
