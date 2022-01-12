// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "./services/PublisherService.sol";
import "./services/ArticleService.sol";
import "./utils/Context.sol";

contract App is Context, PublisherService, ArticleService {

	modifier verifyArticleIndex(uint256 _articleIndex, uint256 _articleNumber) {
		require(publishedArticles[_msgSender()][_articleIndex] == _articleNumber, "Incorrect article index");
		_;
	}

	/**
	 * @dev Get list of articles published by `_publisher`
	 */
	function articlesOf(address _publisher) public view returns(uint256[] memory) {
		return publishedArticles[_publisher];
	}

	/**
	 * @dev Publish new article
	 */
	function publishArticle(string memory _contentHash, ArticleScope _scope) public validateContentHash(_contentHash) returns(uint256) {
		address sender = _msgSender();
		uint256 articleNumber = articleGlobalIndex;

		require(sender != address(0x0));

		Article memory newArticle = Article(
			articleNumber,
			1,
			sender,
			_contentHash,
			_scope,
			block.timestamp,
			0
		);

		articles[articleGlobalIndex] = newArticle;
		publishedArticles[sender].push(articleGlobalIndex);

		emit ArticlePublished(articleGlobalIndex, sender);
		articleGlobalIndex++;

		return articleNumber;
	}

	/** 
	 * @dev Update `_contentHash` of article by `_articleNumber`
	 */
	function updateContentHashOfArticle(uint256 _articleNumber, string memory _contentHash) public 
		validateArticleNumber(_articleNumber) 
		verifyArticleOwnership(_articleNumber) 
		validateContentHash(_contentHash) {

		articles[_articleNumber].contentHash = _contentHash;
		_upgradeMetadataOfArticle(_articleNumber);
		emit ArticleUpdated(_articleNumber);
	}

	/**
	 * @dev Update scope of article by `_articleNumber`
	 */
	function updateScopeOfArticle(uint256 _articleNumber, ArticleScope _scope) public
		validateArticleNumber(_articleNumber)
		verifyArticleOwnership(_articleNumber) {

		articles[_articleNumber].scope = _scope;
		_upgradeMetadataOfArticle(_articleNumber);
		emit ArticleUpdated(_articleNumber);
	}

	/**
	 * @dev Delete single article by `_articleNumber`
	 */
	function deleteArticle(uint256 _articleIndex, uint256 _articleNumber) public 
		validateArticleNumber(_articleNumber)
		verifyArticleIndex(_articleIndex, _articleNumber)
		verifyArticleOwnership(_articleNumber) 
		returns(bool) {

		address sender = _msgSender();

		delete articles[_articleNumber];
		delete publishedArticles[sender][_articleIndex];
		return true;
	}
	
	/**
	 * @dev Transfer ownership of article to `_newOwner`
	 */
	function transferOwnershipOfArticle(uint256 _articleIndex, uint256 _articleNumber, address _newOwner) public
		validateArticleNumber(_articleNumber) 
		verifyArticleIndex(_articleIndex, _articleNumber)
		verifyArticleOwnership(_articleNumber) {

		address sender = _msgSender();

		require(_newOwner != address(0x0));

		delete publishedArticles[sender][_articleIndex];
		publishedArticles[_newOwner].push(_articleNumber);
	}
}
