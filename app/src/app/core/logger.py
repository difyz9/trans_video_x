import logging
import logging.handlers
from datetime import datetime
from pathlib import Path


def setup_logger(name: str, log_dir: str = "logs") -> logging.Logger:
    """
    Set up a logger with both file and console handlers

    Args:
        name: Logger name
        log_dir: Directory to store log files

    Returns:
        logging.Logger: Configured logger instance
    """
    # Create logger
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)

    # Create logs directory if it doesn't exist
    log_path = Path(log_dir)
    log_path.mkdir(parents=True, exist_ok=True)

    # Create formatters
    file_formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    console_formatter = logging.Formatter(
        '%(levelname)s: %(message)s'
    )

    # File handler (daily rotation)
    today = datetime.now().strftime('%Y-%m-%d')
    file_handler = logging.handlers.TimedRotatingFileHandler(
        filename=log_path / f"{name}_{today}.log",
        when='midnight',
        interval=1,
        backupCount=30,  # Keep logs for 30 days
        encoding='utf-8'
    )
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(file_formatter)

    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(console_formatter)

    # Add handlers to logger
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)

    return logger


def get_logger(name: str) -> logging.Logger:
    """
    Get or create a logger

    Args:
        name: Logger name

    Returns:
        logging.Logger: Logger instance
    """
    logger = logging.getLogger(name)
    if not logger.handlers:  # Only setup if no handlers exist
        logger = setup_logger(name)
    return logger
