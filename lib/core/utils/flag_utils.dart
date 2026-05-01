class FlagUtils {
  static String getFlagUrl(String code) {
    return 'https://flagcdn.com/w80/${code.toLowerCase()}.png';
  }
}