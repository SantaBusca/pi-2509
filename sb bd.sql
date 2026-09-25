CREATE DATABASE IF NOT EXISTS santa_busca
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE santa_busca;

CREATE TABLE IF NOT EXISTS estabelecimentos (
  id VARCHAR(64) PRIMARY KEY,
  nome VARCHAR(150) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  senha_hash VARCHAR(255) NOT NULL,
  cnpj CHAR(18) NOT NULL UNIQUE,
  endereco VARCHAR(255) NOT NULL,
  coordenadas VARCHAR(60) NOT NULL,
  tipo ENUM('farmacia','comercio','posto','supermercado') NOT NULL,
  abertura TIME NULL,
  fechamento TIME NULL,
  dias JSON NOT NULL,
  logo MEDIUMTEXT NULL,
  foto MEDIUMTEXT NULL,
  criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS produtos (
  id VARCHAR(64) PRIMARY KEY,
  estabelecimento_id VARCHAR(64) NOT NULL,
  nome VARCHAR(150) NOT NULL,
  marca VARCHAR(100) NOT NULL,
  categoria VARCHAR(60) NOT NULL,
  unidade VARCHAR(30) NOT NULL DEFAULT 'unidade',
  preco DECIMAL(10,2) NOT NULL,
  emoji VARCHAR(10) NULL,
  disponibilidade ENUM('disponivel','esgotado') NOT NULL DEFAULT 'disponivel',
  origem_catalogo TINYINT(1) NOT NULL DEFAULT 0,
  chave VARCHAR(255) NOT NULL,
  criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_produtos_chave (chave),
  INDEX idx_produtos_estabelecimento (estabelecimento_id),
  CONSTRAINT fk_prod_est FOREIGN KEY (estabelecimento_id) REFERENCES estabelecimentos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ofertas (
  id VARCHAR(64) PRIMARY KEY,
  chave VARCHAR(255) NOT NULL,
  estabelecimento_id VARCHAR(64) NOT NULL,
  produto VARCHAR(150) NOT NULL,
  marca VARCHAR(100) NULL,
  preco DECIMAL(10,2) NOT NULL,
  inicio DATETIME NULL,
  fim DATETIME NULL,
  criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_ofertas_chave (chave),
  UNIQUE KEY uk_oferta_estabelecimento_chave (estabelecimento_id, chave),
  CONSTRAINT fk_offer_est FOREIGN KEY (estabelecimento_id) REFERENCES estabelecimentos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS denuncias (
  id VARCHAR(64) PRIMARY KEY,
  usuario VARCHAR(64) NOT NULL,
  chave VARCHAR(255) NOT NULL,
  produto VARCHAR(150) NOT NULL,
  marca VARCHAR(100) NULL,
  estabelecimento VARCHAR(150) NOT NULL,
  preco_atual DECIMAL(10,2) NULL,
  novo_preco DECIMAL(10,2) NULL,
  comprovante MEDIUMTEXT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'REGISTRADO',
  data_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  mes CHAR(7) NOT NULL,
  INDEX idx_denuncias_usuario (usuario),
  INDEX idx_denuncias_chave (chave),
  INDEX idx_denuncias_mes (mes),
  INDEX idx_denuncias_chave_mes (chave, mes)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS pontos_eventos (
  id VARCHAR(64) PRIMARY KEY,
  usuario VARCHAR(64) NOT NULL,
  mes CHAR(7) NOT NULL,
  quantidade INT NOT NULL,
  motivo VARCHAR(150) NULL,
  tipo ENUM('confirmacao','denuncia','outro') NOT NULL DEFAULT 'outro',
  data_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_pontos_usuario (usuario),
  INDEX idx_pontos_mes (mes),
  INDEX idx_pontos_usuario_mes (usuario, mes)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS acoes_usuario (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  usuario VARCHAR(64) NOT NULL,
  chave VARCHAR(255) NOT NULL,
  acao ENUM('confirmar','denuncia') NOT NULL,
  mes CHAR(7) NOT NULL,
  data_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_acao_usuario (usuario, chave, acao, mes),
  INDEX idx_acoes_usuario_mes (usuario, mes)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS produtos_removidos (
  estabelecimento_id VARCHAR(64) NOT NULL,
  chave VARCHAR(255) NOT NULL,
  PRIMARY KEY (estabelecimento_id, chave),
  CONSTRAINT fk_removed_est FOREIGN KEY (estabelecimento_id) REFERENCES estabelecimentos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS historico_precos (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  chave VARCHAR(255) NOT NULL,
  preco DECIMAL(10,2) NOT NULL,
  data_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  origem VARCHAR(60) NOT NULL,
  INDEX idx_historico_chave (chave),
  UNIQUE KEY uk_historico (chave, preco, data_registro, origem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Alertas de preço: só podem ser criados pelo usuário quando ele tiver 26+ pontos no mês.
CREATE TABLE IF NOT EXISTS alertas_preco (
  id VARCHAR(64) PRIMARY KEY,
  usuario VARCHAR(64) NOT NULL,
  chave VARCHAR(255) NOT NULL,
  produto VARCHAR(150) NOT NULL,
  marca VARCHAR(100) NULL,
  estabelecimento VARCHAR(150) NOT NULL,
  preco_alvo DECIMAL(10,2) NOT NULL,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_alertas_usuario (usuario),
  INDEX idx_alertas_chave (chave),
  INDEX idx_alertas_ativos (usuario, ativo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS buscas (
  id VARCHAR(64) PRIMARY KEY,
  usuario VARCHAR(64) NULL,
  consulta VARCHAR(180) NOT NULL,
  consulta_normalizada VARCHAR(180) NOT NULL,
  mes CHAR(7) NOT NULL,
  data_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_buscas_mes (mes),
  INDEX idx_buscas_consulta (consulta_normalizada),
  INDEX idx_buscas_mes_consulta (mes, consulta_normalizada)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS visualizacoes_estabelecimentos (
  id VARCHAR(64) PRIMARY KEY,
  estabelecimento_id VARCHAR(64) NOT NULL,
  sessao VARCHAR(64) NULL,
  mes CHAR(7) NOT NULL,
  data_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_views_estabelecimento (estabelecimento_id),
  INDEX idx_views_mes (mes),
  INDEX idx_views_estabelecimento_mes (estabelecimento_id, mes),
  CONSTRAINT fk_view_estabelecimento FOREIGN KEY (estabelecimento_id) REFERENCES estabelecimentos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS notificacoes_preco (
  id VARCHAR(64) PRIMARY KEY,
  usuario VARCHAR(64) NOT NULL,
  produto VARCHAR(150) NOT NULL,
  marca VARCHAR(100) NULL,
  estabelecimento VARCHAR(150) NOT NULL,
  preco DECIMAL(10,2) NOT NULL,
  preco_alvo DECIMAL(10,2) NOT NULL,
  tipo VARCHAR(40) NOT NULL DEFAULT 'preco_baixou',
  data_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_notificacoes_usuario (usuario),
  INDEX idx_notificacoes_data (usuario, data_registro)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
